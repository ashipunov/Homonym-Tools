<html>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<body>

<h1>GNI trusted sources processor for binomials</h1>

<p>Process any list from GNI trusted source against the given set of other lists, find external and internal homonyms for binomials, and supply 4 new columns.

<hr width="30%" align="left">

<form method="post" action="ctrusted.php">

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
$input_file = "../tmp/ctrusted_selected.tmp";

$fp = fopen($input_file, 'w');
$fw = fwrite($fp, $what . "\n");
foreach ($against as $ag) 
	{
	fwrite($fp, $ag . "\n");
	}
fclose($fp);

$tmp = `cd ../r; Rscript ctrusted.r`;

}

?>

<p>Results (Darwin Core archive files):<br /><br />

<?php
if ($handle = opendir('../output')) {
    while (false !== ($file = readdir($handle))) {
        if ($file != "." && $file != ".." && (strpos($file, ".tgz") !== false) && (strpos($file, "binomials_") !== false)) {
            echo '<a href="../output/'.$file.'">'.$file.'</a><br />';
        }
    }
    closedir($handle);
}
?>

<br><br>
<hr width="30%" align="left">
<hr width="30%" align="left">

<p>The first stage is similar to trusted sources processor, but is this case separate R object based on special GNI query is created. This oblect  contain, among others, two colums: one with normalized scientific names (binomial + author), the other with artificially created binomial names. These names were created from parsing results word1 and word2. As in trusted sources processor, R object will be re-created from sources if saved file is older than 1 day. 

<p>On the second stage, R picks up the file with options (names of lists) created via PHP. Then R code starts to work with list in order to determine internal and external homonyms in both binomials and scientificNames columns, and then determine which binomial homonyms are NOT scientificNames (in other words, which binomial homonyms have different authorship). In the end of this stage, four new colums are created: ExternalHomonymFlagBinomial, InternalHomonymFlagBinomial, ExternalHomonymFlagDiffAuthors, and InternalHomonymFlagDiffAuthors (names should be self-explaining). All column are in binary (0/1) format.

<p>Resulted list (with four additional columns) is written to CSV file which is in turn a component of Darwin Core zipped tar archive. Two other files in archive (meta.xml and eml.xml, different from files used for trusted sources processor) contain meta-information about CSV file. Format of these files will be most probably changed in a future.

</body>
</html>