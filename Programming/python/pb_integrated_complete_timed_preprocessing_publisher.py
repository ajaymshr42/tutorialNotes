
# coding: utf-8

# In[1]:

from pyspark import SparkConf,SparkContext,SQLContext
from pyspark.sql import SQLContext
from pyspark.sql.types import *
from pyspark.sql.functions import lit
from pyspark.sql.functions import UserDefinedFunction,split
from pyspark.sql.types import StringType, NumericType
import pandas as pd 
import numpy as np
import sys
import re
import requests
import json
import traceback


# In[2]:

try:

    try:
        timespan=str(sys.argv[1])
    except IndexError:
        print 'please pass timespan in argument'
        sys.exit()

    conf = (SparkConf().setMaster("local").setAppName("hi_report_app").set("spark.executor.memory", "1g"))
    sc = SparkContext(conf = conf)
    sc.setLogLevel("Error")
    sqlContext = SQLContext(sc)
    # In[2]:

    config_url='https://s3-ap-southeast-1.amazonaws.com/nlplive.humanindex.data/config.json'
    try:
        config_response=requests.get(config_url)
        config = json.loads(config_response.content)
    except:
        print "Cannot fetch Config......"

    # In[23]:

    try:
        fetch_response=requests.get(str(config['baseAPIUrl'])+'/'+str(config['version'])+'/preProcessing/GetPredictionFileJob/'+timespan+'/publisher')
        #check if api request is successfull or not
        if(fetch_response.status_code==200):
            fetch_content=json.loads(fetch_response.content)
            #get the complete path to fetch data
            fetch_path=str(fetch_content['raw_complete_path'])
             #get the complete path to fetch daily data
            daily_fetch_path=str(fetch_content['daily_complete_path'])
            #get job id for acknowledgement purpose
            file_type=str(fetch_content['type'])
            fetch_job_id=int(fetch_content['job_id'])
            # save path for preprocessed files
            save_file_name=str(fetch_content['summary_file_names'])
            save_path=str(fetch_content['summary_file_prefix'])+'/'+str(fetch_content['summary_file_names'])
        else:
            if(str(json.loads(fetch_response.content)['Message'])=="Current job in process"):
                print "Another Job in Progress"
            else:
                print 'Api Call Failed'
    except:
        print "Cannot create Fetch request"


    # In[25]:

    print "Data fetch started"
    try:
        mydf = sqlContext.read.json(fetch_path)
        mydf.registerTempTable("testtable")
    except:
        traceback.print_exc()
        print 'Data of this time timespan is not present in s3'
        print fetch_path
        url = str(config['baseAPIUrl'])+'/'+str(config['version'])+'/preProcessing/acknowledgePredictionFileJob?isProcessed=noData'
        headers = {"content-type": "application/json" }
        try:
            ack_response = requests.put(url, data=json.dumps("job_id":fetch_job_id), headers=headers)          
            if(ack_response.status_code==204):
                print "Successfull Acknowledgement"
                sys.exit(0)
        except:
            print "Cannot create Aknowledgement request"  



    # In[33]:

    #### compelete publisher_part for daily processing script for calculating
    #### maintaining caching saving and finally pushing data to redis


    # function which pushes payloads to redis to be saved in Publisher and User_Identifier format
    def pushToRedis(payload):
        url=str(config['baseAPIUrl'])+'/'+str(config['version'])+'/thirdparty/addIdentifierData'
        headers = {"content-type": "application/json" }
        try:
            data_pusher=requests.post(url,data=json.dumps([payload]),headers=headers)
            if(data_pusher.status_code==200):
                print data_pusher.content
            else:
                print "Failed to push batch"
        except:
            print "Unable to create API Request"
    # function which receives list of publisher and user_identifier data 
    #and creates suitable payloads to be pushed to redis
    def sendPubDataToRedis(pubs):
        #config variable
        batch_size=1000
            
        pub_data={}
        for pub in pubs:
            if(str(pub['publisher_id']) not in pub_data.keys()):
                pub_data[str(pub['publisher_id'])]={}
                pub_data[str(pub['publisher_id'])]['publisher_id']=str(pub['publisher_id'])
            if('data' not in pub_data[str(pub['publisher_id'])].keys()):
                pub_data[str(pub['publisher_id'])]['data']=[]
            d={}
            d['identifier']=str(pub['user_identifier'])
            d['dfp']={}
            for dfp,count in zip(pub['dfps'],pub['dfp_counts']):
                d['dfp'][str(dfp)]=count
            d['session_id']={}
            for session,count in zip(pub['sessions'],pub['session_counts']):
                d['session_id'][str(session)]=count
            d['ip']={}
            for ip,count in zip(pub['ips'],pub['ip_counts']):
                d['ip'][str(ip)]=count
            pub_data[str(pub['publisher_id'])]['data'].append(d)
        
        for key in pub_data:
            payload={}
            payload['publisher_id']=key
            payload['data']=[]
            if(len(pub_data[key]['data'])>batch_size):
                total_len=len(pub_data[key]['data'])
                for index in range(0,total_len/batch_size,batch_size):
                    if(index+batch_size>total_len):
                        payload['data']=pub_data[key]['data'][index:total_len-index]
                    else:
                        payload['data']=pub_data[key]['data'][index:index+batch_size]
                pushToRedis(payload)
            else:
                
                payload['data']=pub_data[key]['data']
                pushToRedis(payload)
                    
    # cerating publisher realted data from daily data 
    pub_dfp_df=sqlContext.sql('select publisher_id,id5 as user_identifier, collect_list(device_finger_print) as dfps , collect_list(c_dfp) as dfp_counts from (select publisher_id ,id5, device_finger_print ,count(device_finger_print) as c_dfp  from testtable where id5!="" group by publisher_id,id5,device_finger_print)  group by publisher_id,id5')
    pub_ip_df=sqlContext.sql('select publisher_id,id5 as user_identifier, collect_list(ip) as ips , collect_list(c_ip) as ip_counts from (select publisher_id ,id5, ip ,count(ip) as c_ip  from testtable where id5!="" group by publisher_id,id5,ip) group by publisher_id,id5')
    pub_session_df=sqlContext.sql('select publisher_id,id5 as user_identifier, collect_list(sessionId) as sessions , collect_list(c_session) as session_counts from (select publisher_id ,id5, sessionId ,count(sessionId) as c_session  from testtable where id5!="" group by publisher_id,id5,sessionId) group by publisher_id,id5')
    pub_df=pub_dfp_df.join(pub_ip_df,['publisher_id','user_identifier'],'outer')
    pub_df=pub_df.join(pub_session_df,['publisher_id','user_identifier'],'outer')
    pub_daily_df=sqlContext.read.json(daily_fetch_path)

    if(len(pub_daily_df.columns)==0):
        for dtype in pub_df.dtypes:
            pub_daily_df=pub_daily_df.withColumn(dtype[0],lit(None).cast(dtype[1]))
            
    pub_daily_df=pub_daily_df.select(pub_df.columns)
    pub_df=pub_df.union(pub_daily_df)


    pub_daily_df=pub_daily_df.select(pub_df.columns)
    pub_df=pub_df.union(pub_daily_df)
    pub_df.write.mode('append').json("{}".format(save_path),"overwrite")
    pub_df.cache()
    pubs=pub_df.collect()
    sendPubDataToRedis(pubs)
    data={"job_id":fetch_job_id,"file_name":save_file_name,"type":file_type}
    #creating acknowledgement request
    url = str(config['baseAPIUrl'])+'/'+str(config['version'])+'/preProcessing/acknowledgePredictionFileJob'
    # Create your header as required
    headers = {"content-type": "application/json" }
    try:
        ack_response = requests.put(url, data=json.dumps(data), headers=headers)
        #checking if aknowledgement is successfull or not
        
        if(ack_response.status_code==204):
            print "Successfull Acknowledgement"
        else:
            print "Acknowledgement Unsuccessfull"
    except:
        print "Cannot create Aknowledgement request"

except:
    traceback.print_exc()
    print 'script failed to execute'
    print fetch_path
    # negative acknowledgement
    url = str(config['baseAPIUrl'])+'/'+str(config['version'])+'/preProcessing/acknowledgePredictionFileJob?isProcessed=fail'
    headers = {"content-type": "application/json" }
    try:
        ack_response = requests.put(url, data=json.dumps("job_id":fetch_job_id), headers=headers)          
        if(ack_response.status_code==204):
            print "Successfull negative Acknowledgement ===> Script Failure"
    except:
        print "Cannot create Aknowledgement request"

