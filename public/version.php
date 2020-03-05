<?php
$gitBasePath   = __DIR__ . '/../.git';
$gitStr        = file_get_contents($gitBasePath.'/HEAD');
$gitBranchName = rtrim(preg_replace("/(.*?\/){2}/", '', $gitStr));
$gitPathBranch = $gitBasePath.'/refs/heads/'.$gitBranchName;
$gitHash       = file_get_contents($gitPathBranch);
$gitDate       = new DateTime(date(DATE_ATOM, filemtime($gitPathBranch)));
$branchParts   = explode('release/', $gitBranchName);

if (count($branchParts) === 2) {
    $version = $branchParts[1];
} else {
    $version = $gitBranchName;
}
echo $version . '<br />' . $gitDate->format('m/d/Y H:i') . ' UTC';
