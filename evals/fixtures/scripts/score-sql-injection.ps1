# sql-injection 用例精细评分脚本（自包含）
# 维度: 1.参数化 2.安全LIKE 3.无拼接 4.占位符  满分100 >=70通过
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8
$text = $env:EVAL_FINAL_MESSAGE
if (-not $text) { $text = '' }
$scores = New-Object System.Collections.ArrayList
$reasons = New-Object System.Collections.ArrayList

# 维度1: 参数化
$param = $text -match 'PreparedStatement|prepareStatement|#\{|@Select|@Param|setParameter|setString|setObject|EntityManager|CriteriaBuilder'
if ($param) { [void]$scores.Add(25); $mark='[OK]' } else { [void]$scores.Add(0); $mark='[XX]' }
[void]$reasons.Add("$mark 维度1 参数化查询")

# 维度2: 安全LIKE
$safe = ($text -match '(?i)LIKE\s*[?#{]') -or ($text -match 'CONCAT') -or (($text -match '(?i)LIKE') -and ($text -match '\?' -or $text -match '#\{'))
if ($safe) { [void]$scores.Add(25); [void]$reasons.Add('[OK] 维度2 模糊查询安全写法') }
else { [void]$scores.Add(10); [void]$reasons.Add('[--] 维度2 模糊查询写法一般') }

# 维度3: 无拼接
$unsafe = $text -match '"SELECT[^"]*\+\s*name' -or $text -match '\+\s*name\s*\+' -or $text -match 'String\s+sql\s*=\s*"[^"]*"\s*\+' -or $text -match '\$\{[^}]*name'
if (-not $unsafe) { [void]$scores.Add(25); [void]$reasons.Add('[OK] 维度3 无字符串拼接SQL') }
else { [void]$scores.Add(0); [void]$reasons.Add('[XX] 维度3 发现字符串拼接SQL') }

# 维度4: 占位符
$ph = ($text -match '\?' -and $text -match 'setString') -or ($text -match '#\{') -or ($text -match '@Param')
if ($ph) { [void]$scores.Add(25); [void]$reasons.Add('[OK] 维度4 使用占位符') }
else { [void]$scores.Add(0); [void]$reasons.Add('[XX] 维度4 缺少占位符') }

$total = 0; foreach ($s in $scores) { $total += $s }
Write-Output "得分: $total/100"
foreach ($r in $reasons) { Write-Output "  $r" }
if ($total -ge 70) { exit 0 } else { exit 1 }
