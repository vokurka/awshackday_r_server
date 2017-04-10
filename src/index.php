<?php

if (!empty($_GET['type']) && $_GET['type'] == 'car')
{
	$message = exec('Rscript car.R');
}
else if (!empty($_GET['type']) && $_GET['type'] == 'washingmachine')
{
	$message = exec('Rscript washingmachine.R');	
}
else
{
	$message = "I have no info on that.";
}

$message = str_replace('[1]', '', $message);
$message = str_replace('"', '', $message);

echo $message;