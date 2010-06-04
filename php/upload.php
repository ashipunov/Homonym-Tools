<html>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<body>

<h1>Uploaded file processor</h1>

<p>Takes the file in given format (2-column tab separated), find homonyms, separate them, sort all non-homonyms by name, place all homonyms to the end and supply homonym flags.

<p><a href="../doc/upload_example.txt">Example</a> for upload.

<hr width="30%" align="left">

<form enctype="multipart/form-data" action="upload.php" method="POST">
<input type="hidden" name="MAX_FILE_SIZE" value="100000" />
Choose a file to upload: <input name="uploadedfile" type="file" /><br />
<input type="submit" value="Upload and process" />

&nbsp;&nbsp;against:&nbsp;&nbsp;
<input type="checkbox" name="against[]" value="IF" /><b>IF</b> &nbsp;&nbsp;AND
<input type="checkbox" name="against[]" value="IPNI" /><b>IPNI</b> &nbsp;&nbsp;AND
<input type="checkbox" name="against[]" value="ZB" /><b>ZB</b> &nbsp;&nbsp;AND
<input type="checkbox" name="against[]" value="NZ" /><b>NZ</b> &nbsp;&nbsp;
</form>


<?php

$target_path = "../tmp/upload.tmp"; 

if(!move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $target_path))
	{
	echo "There was an error uploading the file, please try again!";
	}
else
	{
	$against = $_POST['against'];
	$input_file = "../tmp/upload_selected.tmp";
	$fp1 = fopen($input_file, 'w');
	foreach ($against as $ag) 
		{
		fwrite($fp1, $ag . "\n");
		}
	fclose($fp1);
	$tmp = `cd ../r; Rscript upload.r`;
	}

?>

<hr width="30%" align="left">

<p><a href='../tmp/upload_output.tmp'>Processed</a> file.

<br><br>
<hr width="30%" align="left">
<hr width="30%" align="left">

<p>The process is simple enough: all trusted sources are loaded as R object from disk (see documentstion for trusted sources processor), and R takes two files: uploaded file and temporary file which PHP writes to disk and which contains names of sources to compare with uploaded list. The list should be exactly in the format described above. However, it is possible to skip first column (taxon IDs) and supply only names. It is also possible to supply more than two columns. In this case, all extra columns will be ignored.

<p>Overall, homonym search is the same as in trusted sources processor. But results are slightly different: instead of Darwin Core archive, this is simply a temporary CSV file with the same structure as DC CSV file (see documentstion in trusted sources processor).

</body>
</html>