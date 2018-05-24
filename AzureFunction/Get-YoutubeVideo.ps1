Write-Output "PowerShell Timer trigger function executed at:$(get-date)";

# 1. collect youtube data
# 2. select random video title and url
# 3. compose a new tweet text with hashtags
# 4. authenticate to twitter and publish tweet

Function Get-YouTubeVideo{
    [cmdletBinding()]
    param(
        [string]$Username
    )

    $Links = iwr "https://www.youtube.com/user/$Username/videos?view=0&sort=dd&flow=grid" -UseBasicParsing | % links
    $Links | Where-Object{$_.href -like '*watch*' -and ![string]::IsNullOrWhiteSpace($_.title)} |
             ForEach-Object {
                 [PSCustomObject] @{                     
                     title=$_.title
                     url= "youtu.be/{0}" -f $_.href.replace("watch?v=",'')
                 }
             }
}

# gets a random video
$data = Get-YouTubeVideo -Username 'prateeksingh1590' | Get-Random

# convert specific words to hash tags
$tweet = $data.title + "`n" +  $data.url
$hashtags = 'powershell','cloud','azure','aws','automation'
$tweet = $tweet.split(' ').foreach({if($_ -in $hashtags){'#'+$_}else{$_} }) -join ' ' 

# make sure tweet length is not more than 280
if($tweet.length -le 280){
   
# Setup Twitter OAuth Hashtable
$OAuths = @{
    'ApiKey' = $env:consumerkey; 
    'ApiSecret' = $env:consumersecret; 
    'AccessToken' = $env:accesstoken; 
    'AccessTokenSecret' = $env:accesssecret
}

$Parameters = @{ 'status' = $tweet} 

Invoke-TwitterRestMethod -ResourceURL 'https://api.twitter.com/1.1/statuses/update.json' -RestVerb 'POST' -Parameters $Parameters -OAuthSettings $OAuths
    if($?){ # if previous was succesful.
        Write-Output "Tweet published > $tweet" 
    }
}
