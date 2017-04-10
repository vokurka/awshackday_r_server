<?php

if (!empty($_GET['type']) && $_GET['type'] == 'taxi')
{
	$message = exec('Rscript hd_taxi.R');
}
else if (!empty($_GET['type']) && $_GET['type'] == 'washingmachine')
{
	$message = exec('Rscript hd_washing_machine.R');	
}
else if (!empty($_GET['type']) && $_GET['type'] == 'garden')
{
	$message = exec('Rscript hd_garden.R');	
}
else
{
	$message = "I have no info on that.";
}

$message = str_replace('[1]', '', $message);
$message = str_replace('"', '', $message);

echo $message;