<?php

// error_reporting (E_ALL);
// ini_set('display_errors', 1);
include 'bloom.class.php';
$parameters = array(
  'entries_max' => 1
);
$bloom = new Bloom($parameters);
file_put_contents( 'cache', serialize($bloom));

?>

