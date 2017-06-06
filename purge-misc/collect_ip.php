<?php
	require_once '/var/www/html/s3/vendor/autoload.php';
	use Aws\S3\S3Client;

	$s3 = S3Client::factory(array(keys));
	
	$collector_urls=array(
			'https://lists.blocklist.de/lists/bruteforcelogin.txt',
			'http://www.unsubscore.com/blacklist.txt',
			'https://raw.githubusercontent.com/maravento/blackip/master/blackip.txt',
			'https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset',
			'http://blocklist.greensnow.co/greensnow.txt',
			'https://www.openbl.org/lists/base.txt',
			'http://cinsscore.com/list/ci-badguys.txt',
			'http://rules.emergingthreats.net/blockrules/compromised-ips.txt',
			'https://zeustracker.abuse.ch/blocklist.php?download=badips',
			'https://zeustracker.abuse.ch/blocklist.php?download=ipblocklist',
			'https://zeustracker.abuse.ch/blocklist.php?download=squidip',
			'https://ransomwaretracker.abuse.ch/downloads/RW_IPBL.txt',
			'https://ransomwaretracker.abuse.ch/downloads/CW_PS_IPBL.txt',
			'https://ransomwaretracker.abuse.ch/downloads/TC_PS_IPBL.txt',
			'https://ransomwaretracker.abuse.ch/downloads/LY_C2_IPBL.txt',
			'https://ransomwaretracker.abuse.ch/downloads/LY_PS_IPBL.txt',
			'https://ransomwaretracker.abuse.ch/downloads/TL_C2_IPBL.txt',
			'https://ransomwaretracker.abuse.ch/downloads/TL_PS_IPBL.txt',
			'https://feodotracker.abuse.ch/blocklist/?download=ipblocklist',
			'https://feodotracker.abuse.ch/blocklist/?download=badips',
			'https://lists.blocklist.de/lists/all.txt',
			'https://lists.blocklist.de/lists/ssh.txt',
			'https://lists.blocklist.de/lists/mail.txt',
			'https://lists.blocklist.de/lists/apache.txt',
			'https://lists.blocklist.de/lists/imap.txt',
			'https://lists.blocklist.de/lists/imap.txt',
			'https://lists.blocklist.de/lists/sip.txt',
			'https://lists.blocklist.de/lists/bots.txt',
			'https://lists.blocklist.de/lists/strongips.txt',
			'https://lists.blocklist.de/lists/ircbot.txt');

	$ip_array=array();
	$ip_count=0;
	$ip_log=array();

	foreach ($collector_urls as $key => $value) {
		$k=0;
		$tmp_ip_array=array();
		try{
			$ip_file=fopen($value,"r");
			while (!feof($ip_file)) {
				$str=fgets($ip_file);
				$new_str=explode(".",$str);
				if(is_numeric($new_str[0])){
					// if (!in_array($str,$ip_array))
					$ip_array[$ip_count++]=$str;
					$tmp_ip_array[$k++]=$str;
				}
			}
			$tmp_make_name=explode('//',$value);
			$make_name=explode('/',$tmp_make_name[1]);

			if(count($make_name)==3){
				$name_in_key=$make_name[0].'-'.$make_name[1].'-'.$make_name[2];
			}else if(count($make_name)==2){
				$name_in_key=$make_name[0].'-'.$make_name[1];
			}else {
				$name_in_key=$make_name[0];
			}
			echo $name_in_key." done\n";

			exec("touch abc");
			file_put_contents("abc", $tmp_ip_array);

			$s3->putObject(array(
			    'Bucket' => 'blacklist.ip.bucket',
			    'Key'    => $name_in_key,
			    'Body'   =>  file_get_contents("abc")
			));

			exec("rm abc");

			$ip_log[$name_in_key]=json_encode(array('status'=>'success','count'=>$k,'key'=>$name_in_key,'url'=>$value));
		}catch(Exception $e){
			print("Something wrong with file ".$value."<br>");
			$ip_log->$name_in_key=array('status'=>'failed','count'=>0);
		}
	} 

	exec("touch abc");
	file_put_contents("abc", $ip_array);
	$s3->putObject(array(
	    'Bucket' => 'blacklist.ip.bucket',
	    'Key'    => 'final_ip_collected_blacklist',
	    'Body'   =>  file_get_contents("abc")
	));

	exec("rm abc");
	exec("touch abc");
	file_put_contents("abc", json_encode($ip_log));
	$s3->putObject(array(
	    'Bucket' => 'blacklist.ip.bucket',
	    'Key'    => 'source-log',
	    'Body'   =>  file_get_contents("abc")
	));

	exec("rm abc");
	// echo $result['Body'];
?>
