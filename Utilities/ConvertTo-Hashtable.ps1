Function ConvertTo-Hashtable($Path){
    $hashtable = @{}
    foreach($item in $(Import-Csv $Path)){
        $hashtable[$item.key] = $item.Value
    }
    $hashtable
}
