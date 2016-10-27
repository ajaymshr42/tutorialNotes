<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

require_once '/var/www/vendor/autoload.php';
use Fluent\Logger\FluentLogger;

class Adviewability extends CI_Controller {

	public function index(){
		echo "Error: Fatal termination error!";
	}

	public function savePixelsToLog($apikey,$jsonstring){
		//fired pixels recieved at this function and saved to logs for tags

		if($jsonstring!==''){
			$jsonObject=base64_decode($jsonstring);
			$temp=html_entity_decode($jsonObject);
			$obj = json_decode($temp);

			$count=intval($obj->up);
			$time=intval($obj->mud);
			$visibility=intval($obj->abl);


			$ref=$_SERVER['HTTP_REFERER'];
			$ip=$_SERVER['REMOTE_ADDR'];
			$ua=$_SERVER['HTTP_USER_AGENT'];


			$this->load->library('CouchbaseSession',array("userip"=>$ip));
			$cbSession = $this->couchbasesession->read();
			$couchbase_user_id = $this->couchbasesession->getSessionId(); 

			$this->load->model('rpc/admodel','ad');

			$cbSession['tagData'][$obj->apikey]=$obj;
			$cbSession['tagData']['ip']['ip']=$ip;
			$cbSession['tagData']['ip']['timestamp']=time();
			$cbSession['tagData']['ip']['country']=$this->vp->getCountryFromIP($ip);

			$ch = curl_init();
	        curl_setopt($ch, CURLOPT_URL, "http://data.nlpcaptcha.in/adviewability/api.php?ip=".$ip);
	        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	        $output = curl_exec($ch);
	        curl_close($ch);  
	        $status=json_decode($output);
	        $cbSession['tagData']['ip']['blacklist']=$status->status;
			$cbSession['tagData']['userAgent']=$ua;
			$cbSession['tagData']['referrer']=$ref;
			$tp=json_encode($cbSession);
			$this->sendToFluentd($cbSession);

		}
    }

	private function sendToFluentd($data){
		$logger = new FluentLogger("localhost","24224");
		$logger->post("tag.logs",$data);
	}
		
	public function viewable($apikey='',$data=''){
		// $this->load->model('rpc/visibility','vp');
		$this->savePixelsToLog($apikey,$data);
	}
}

?>