$count = $requestBody.count

if($req_query_name){
    $name = $req_query_name
}
if($req_query_count){
    $count = $req_query_count
}

Write-Verbose "Fetching Top $name subreddits" -Verbose
$rawposts = (Invoke-RestMethod "https://www.reddit.com/r/$name.json?limit=100").data.children.data
$redditposts = foreach($post in $rawposts){
    [PSCustomObject] @{
        name  = $post.name
        ups   = $post.ups
        numcomments = $post.num_comments
        author  = $post.author
        #score = $post.score
        flair = $post.link_flair_text
        createdUTC  = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($post.created_utc))
        title = $post.title
        url     = $post.url
    }
}

$Return =   $redditposts |
            Where-Object {$_.createdutc -gt (get-date).AddDays(-1.25)} |
            Sort-Object ups, numcomments -Descending |
            Select-Object -First $count | 
            convertto-Json |
            Out-String  
Out-File -Encoding Ascii -FilePath $res -inputObject $Return


$uri = 'https://4sysops.azurewebsites.net/api/HttpTriggerPowerShell1?code=YBjqyVAeHtqq3xXu87QaTLPnEpyIVJT0b8osVZcyqqgYoMeckb0mpg=='
irm -Uri "$uri&name=azure&count=3" -Method Get -Verbose
irm -Uri "$uri" -Body $(@{name='Azure';count=2}|ConvertTo-Json) -Method Post -Verbose
