<html>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<body>

<h1>GNI trusted sources processor</h1>

<p>Process any list from GNI trusted source against the given set of other lists, find external and internal homonyms, and supply 2 new columns.

<hr width="30%" align="left">

<form method="post" action="trusted.php">

What to <input type="submit" name="checklist" value="check">&nbsp;:

<input type="radio" name="what" value="IF" /><b>IF</b> &nbsp;&nbsp;OR
<input type="radio" name="what" value="IPNI" /><b>IPNI</b> &nbsp;&nbsp;OR
<input type="radio" name="what" value="ZB" /><b>ZB</b> &nbsp;&nbsp;OR
<input type="radio" name="what" value="NZ" /><b>NZ</b> &nbsp;&nbsp;&mdash;

against&mdash;
<input type="checkbox" name="against[]" value="IF" /><b>IF</b> &nbsp;&nbsp;AND
<input type="checkbox" name="against[]" value="IPNI" /><b>IPNI</b> &nbsp;&nbsp;AND
<input type="checkbox" name="against[]" value="ZB" /><b>ZB</b> &nbsp;&nbsp;AND
<input type="checkbox" name="against[]" value="NZ" /><b>NZ</b> &nbsp;&nbsp;

</form>

<hr width="30%" align="left">

<?php

if (isset($_POST['checklist'])) 
{

$what = $_POST['what'];
$against = $_POST['against'];
$input_file = "../tmp/trusted_selected.tmp";

$fp = fopen($input_file, 'w');
$fw = fwrite($fp, $what . "\n");
foreach ($against as $ag) 
	{
	fwrite($fp, $ag . "\n");
	}
fclose($fp);

$tmp = `cd ../r; Rscript trusted.r`;

}

?>

<p>Results (Darwin Core archive files):<br /><br />

<?php

if ($handle = opendir('../output')) {
    while (false !== ($file = readdir($handle))) {
        if ($file != "." && $file != ".." && (strpos($file, ".tgz") !== false) && (strpos($file, "binomials_") === false)) {
            echo '<a href="../output/'.$file.'">'.$file.'</a><br />';
        }
    }
    closedir($handle);
}

?>

<br><br>
<hr width="30%" align="left">
<hr width="30%" align="left">

<p>The first stage in invisible to user: all trusted sources (generated from GNI and standalone) are unified and merged in one R object (data frame). To be precise, R first checks the file on a disk, and if it is fresh (less then one day old), R reads copy from disk to memory; if not, R creates new object from scratch and writes it to the disk. This R object is used also for uploaded file and texbox processors. Since IF (Index Fungorum) does not contain uninomials, these names are taken from binomials and then unique-ized. Therefore, IF does not contain internal homonyms. IPNI and ZooBank lists contain internal homonyms, but they also contain artifical homonyms which resulted from incomplete names parsing. This situation should improve in a future.

<p>On the second stage, when user clicks on the radio and checkboxes, PHP writes temporary file which contains name of list to compare and names of lists which will be used for comparison. Then R code starts to work with list in order to determine internal and external homonyms in comparison with other lists. The code is simple and fast, and uses R ability to vectorize calculations. In the end, two colums are added to initial list: external homonyms colum (this column has a variable name reflects names of lists which are compared), and internal homonyms ("InternalHomonymFlag"). Both columns are in binary (0/1) format.

<p>Resulted list (with two additional columns) is written to CSV file which is in turn a component of Darwin Core zipped tar archive. Two other files in DC archive (meta.xml and eml.xml) contain meta-information about CSV file. Format of these files will be most probably changed in a future.

</body>
</html>