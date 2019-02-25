##BoomTown Technical Interview
##Meagin Arrocha
##Feb. 1, 2019

##set website
$Uri = "http://api.github.com/orgs/BoomTownROI"

##get response
$response = Invoke-WebRequest -Uri $uri

##look at content of website
$content = $response.Content

##setting content variable to test because I exceeded api limit rate otherwise *face palm*
##left to show you thought process
<#--$content = '{
  "login": "BoomTownROI",
  "id": 1214096,
  "node_id": "MDEyOk9yZ2FuaXphdGlvbjEyMTQwOTY=",
  "url": "https://api.github.com/orgs/BoomTownROI",
  "repos_url": "https://api.github.com/orgs/BoomTownROI/repos",
  "events_url": "https://api.github.com/orgs/BoomTownROI/events",
  "hooks_url": "https://api.github.com/orgs/BoomTownROI/hooks",
  "issues_url": "https://api.github.com/orgs/BoomTownROI/issues",
  "members_url": "https://api.github.com/orgs/BoomTownROI/members{/member}",
  "public_members_url": "https://api.github.com/orgs/BoomTownROI/public_members{/member}",
  "avatar_url": "https://avatars3.githubusercontent.com/u/1214096?v=4",
  "description": "",
  "name": "BoomTownROI",
  "company": null,
  "blog": "boomtownroi.com",
  "location": null,
  "email": "",
  "is_verified": false,
  "has_organization_projects": true,
  "has_repository_projects": true,
  "public_repos": 40,
  "public_gists": 0,
  "followers": 0,
  "following": 0,
  "html_url": "https://github.com/BoomTownROI",
  "created_at": "2011-11-22T21:48:43Z",
  "updated_at": "2018-07-31T02:52:20Z",
  "type": "Organization"
}'
--#>

##splitting large string on comma
$results = $content.Split(',')

##go through each result two get created at date, updated date, public repos number
##and urls that match the string and status code criteria
$counter = 0
foreach($item in $results){
    ##get created at string
    if($item -clike "*created_at*"){
        $citem = $item
    }
    ##get updated at string
    elseif($item -clike "*updated_at*"){
        $uitem = $item
    }
    ##get public repos number
    elseif($item -clike "*public_repos*"){
        $temp = $item -creplace "^.+[: ]", ''
        $repos = $temp
    }
    ##only get urls containing certain string
    elseif($item -like '*api.github.com/orgs/BoomTownROI*'){
        #trim to url with no extra characters
        $temp = $item -creplace '^.+(url":)', ''
        $url = $temp -creplace '"', '' 

        ##try to get to site 
        $ValidUrl = $false
        try{
            $wr = Invoke-WebRequest -Uri $url 
            $ValidUrl = $true
        }
        ##catch if the site is showing something other than 200
        ##or throwing an error
        catch{
            Write-Warning "Not a valid URL: `"$url`""
        }
        ##if the url is valid, print out the ids and keys
        if($ValidUrl){
            Write-Host $url' is a good URL! Here are the id keys and values:' -ForegroundColor Cyan
            Write-Host 'Inserting info into output files...' -ForegroundColor Magenta
           
            ##split values into lines by commas
            $vals = $wr.Content.Split(',')

            ##Need Counter for output file numbers
            ##doing this because url has character not allowed in naming files
            $counter++

            ##print output to seperate file
            $str = '.\Documents\OutputFile'+$counter+'.txt'
            $vals | Out-File $str
            start $str
            Write-Host 'Done!' -ForegroundColor Green
            <####tried to seperate the info into a table to look nicer for the user
            ####couldn't get the table to recognize the type of input
            ####als tried to put this in another file but couldn't get call to work correctly
            ####left all of this in here to show thought process
            ##Define Table
            $table = New-Object system.Data.DataTable "OutputTable"

            #Define Columns
            $col1 = New-Object System.Data.DataColumn Info,([Object])
            $col2 = New-Object System.Data.DataColumn Ids,([Object])
            $col3 = New-Object System.Data.DataColumn Values,([Object])
            
            ##Add columns
            $table.columns.add($col1)
            $table.columns.add($col2)
            $table.columns.add($col3)

            ##Create  first row
            $row = $table.NewRow()

            ##go through each line
            foreach($v in $vals){
                ##Create  row
                $row = $table.NewRow()

                ##seperate by whats in between ""
                $arr = $v.Split('"[+]"')
                $arr
                $arr.Count
                ##if there is 3 objects in array then its the id, :, value
                if($arr.count -eq 3){
                    $table.Ids = $arr[1]
                    write-host $arr[1] -ForegroundColor Green
                    $a = $arr[2] -replace '\s',''
                    $a1 = $a.Substring(1,$a.Length-1)
                    $table.Values = $a1
                    write-host $a1 -ForegroundColor Magenta
                }
                elseif($arr.count -eq 4){
                    $table.Ids = $arr[1]
                    Write-Host $arr[1] -ForegroundColor Green
                    $table.Values = $arr[3]
                    Write-Host $arr[3] -ForegroundColor Magenta
                }
                ##else there are 5 objects in in arr
                elseif($arr.count -eq 5){
                    if($arr[0] -eq '' -and $arr[4] -ne '' -and$arr[4] -ne '}'){
                        $table.Info = $arr[1]
                        Write-Host $arr[1] -ForegroundColor Blue
                        $table.Ids = $arr[3]
                        Write-Host $arr[3] -ForegroundColor Green
                        $a = $arr[4] -replace '\s',''
                        $a1 = $a.Substring(1,$a.Length-1)
                        $table.Values = $a1
                        Write-Host $a1 -ForegroundColor Magenta
                    }
                    ##captures most cases where first and last index are empty
                    else{
                        $table.Ids = $arr[1]
                        Write-Host $arr[1] -ForegroundColor Green
                        $table.Values = $arr[3]
                        Write-Host $arr[3] -ForegroundColor Magenta
                    }
                }
                elseif($arr.Count -eq 6){
                    $table.Ids = $arr[1]
                    Write-Host $arr[1] -ForegroundColor Green
                    $table.Values = $arr[3]+$arr[4]
                    Write-Host $arr[3]$arr[4] -ForegroundColor Magenta
                    Write-Host $arr[3]+$arr[4] -ForegroundColor Magenta
                    Write-Host '$arr[3]+$arr[4]' -ForegroundColor Magenta
                }
                ##arr count is 7
                elseif($arr.Count -eq 7){
                    $table.Info = $arr[1]
                    Write-Host $arr[1] -ForegroundColor Blue
                    $table.Ids = $arr[3]
                    Write-Host $arr[3] -ForegroundColor Green
                    $table.Values = $arr[5]
                    Write-Host $arr[5] -ForegroundColor Green
                }
                ##default
                else{
                    $table.Ids = "Error!"
                }
                ##Add the row to the table
                $table.Rows.Add($row)
            }
            ##Display the table
            $table | Format-Table -AutoSize#>
        }
    }
}

################Part 2###################

##setting function to redo date/time values
Function fixDate($value){
    $temp = $value -creplace ".+(: )", ''
    $temp2 = $temp -creplace '"', ''
    $temp3 = $temp2 -creplace 'T', ' '
    $time = $temp3 -creplace 'Z', ''
    return $time
}

##output if updated time is greater than created time
if(fixDate($utime) -gt fixDate($ctime)){
    Write-Host "Updated value is greater than created value" -ForegroundColor Yellow
}
else{
    Write-Host "Updated value is less than or equal to created value" -ForegroundColor DarkRed
}

##increase number of items to return
##add number to amount of public_repos to make sure the total doesn't go over
$perPage = $repos + 30
##make the request to the repos_url site
$c = Invoke-WebRequest -Uri "https://api.github.com/orgs/BoomTownROI/repos?page=1&per_page=$perPage" -Method Get

##seperate large string by id's
$seperator = ',"id":'
##get count of repos by id's
$count = $c.Content -split $seperator
##Subtract one from count for extra instance during call for the page
$cc = $count.Count - 1

##print out if repos counts match
if($cc -ne $repos){
    Write-Host "Count does not match between public_repos count and array of repos count" -ForegroundColor White -BackgroundColor DarkRed
    Write-Host "Count for public_repos is $repos and count in array of repos is $cc" -ForegroundColor White -BackgroundColor DarkRed
}
else{
    Write-Host "Repo counts match!" -ForegroundColor DarkYellow
}
