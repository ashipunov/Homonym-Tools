<html>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<body>

<h1>Textbox processor</h1>

<p>Takes the 2-column list (ID for the first column, name for the second column), find homonyms, and supply the homonym flags.

<p>Example to paste:
<br><pre>
nz001 Acanthatrium
nz002 Acanthilis
nz003 Acanthis
nz004 Acanthis
nz019 Acanthus
nz005 Acanthocausus
nz006 Acanthocranaus
nz007 Acanthocypris
nz008 Acanthodica
nz009 Acanthogryllus
nz010 Acanthohaustorius
nz020 Acanthus
nz021 Acatapaustus
nz022 Aceratocrates
</pre>

<hr width="30%" align="left">

<form method="post" action="textbox.php">
Put your list here: <br><textarea name="msg" rows="8" cols="40">
</textarea>
<br><input type="submit" value="Process">

&nbsp;&nbsp;against:&nbsp;&nbsp;
<input type="checkbox" name="against[]" value="IF" /><b>IF</b> &nbsp;&nbsp;AND
<input type="checkbox" name="against[]" value="IPNI" /><b>IPNI</b> &nbsp;&nbsp;AND
<input type="checkbox" name="against[]" value="ZB" /><b>ZB</b> &nbsp;&nbsp;AND
<input type="checkbox" name="against[]" value="NZ" /><b>NZ</b> &nbsp;&nbsp;
</form>

<hr width="30%" align="left">

<?php

if (isset($_POST['against'])) 
{

$msg = $_POST['msg'];
$against = $_POST['against'];
$input_file = "../tmp/textbox_selected.tmp";

$fp1 = fopen($input_file, 'w');
foreach ($against as $ag) 
	{
	fwrite($fp1, $ag . "\n");
	}
fclose($fp1);

$msg_file = "../tmp/textbox.tmp";

if ($msg != "")
	{
	$fp2 = fopen($msg_file, 'w');
	$fw2 = fwrite($fp2, $msg);
	fclose($fp2);
	}

$tmp = `cd ../r; Rscript textbox.r`;

}
?>

<p><a href='../tmp/textbox_output.tmp'>Processed</a> list as a text file.

<br><br>
<hr width="30%" align="left">
<hr width="30%" align="left">

<p>The process is almost the same as in upload file processor. The only difference is the texbox for input instead of uploaded file.

</body>
</html>