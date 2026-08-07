# null-safety 用例精细评分脚本（自包含）
# 维度: 1.具名校验 2.避免return null 3.空集合 4.吞异常  满分100 >=70通过
$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8
$text = $env:EVAL_FINAL_MESSAGE
if (-not $text) { $text = '' }
$scores = New-Object System.Collections.ArrayList
$reasons = New-Object System.Collections.ArrayList

# 维度1: 具名校验
$check1 = $text -match 'Objects\.requireNonNull|requireNonNull|StringUtils\.isEmpty|StringUtils\.isBlank|Assert\.notNull|Assert\.hasText|Validate\.notNull|Preconditions\.checkNotNull|@NonNull|@NotNull|@NotBlank'
if ($check1) { [void]$scores.Add(25); $mark='[OK]' } else { [void]$scores.Add(0); $mark='[XX]' }
[void]$reasons.Add("$mark 维度1 具名校验API")

# 维度2: 避免 return null
$hasRN = $text -match 'return\s+null\s*;'
$usesOpt = $text -match 'Optional'
$usesExc = $text -match 'throw new|BusinessException|ServiceException|NotFoundException'
if (-not $hasRN) { [void]$scores.Add(25); [void]$reasons.Add('[OK] 维度2 未出现 return null') }
elseif ($usesOpt -or $usesExc) { [void]$scores.Add(15); [void]$reasons.Add('[--] 维度2 有return null但用了Optional/异常') }
else { [void]$scores.Add(0); [void]$reasons.Add('[XX] 维度2 直接return null违反强制') }

# 维度3: 空集合
$hasEC = $text -match 'Collections\.emptyList|List\.of\(\)|emptyList\(\)|Collections\.emptySet|Set\.of\(\)|new ArrayList|new CopyOnWriteArrayList|Stream\.empty'
if ($hasEC) { [void]$scores.Add(25); $mark='[OK]' } else { [void]$scores.Add(0); $mark='[XX]' }
[void]$reasons.Add("$mark 维度3 集合返回空集合")

# 维度4: 吞异常
$hasPS = $text -match 'printStackTrace'
$hasSW = $text -match 'catch\s*\([^)]*\)\s*\{\s*\}'
if (-not $hasPS -and -not $hasSW) { [void]$scores.Add(25); [void]$reasons.Add('[OK] 维度4 未发现吞异常') }
else { [void]$scores.Add(5); [void]$reasons.Add('[XX] 维度4 疑似吞异常') }

$total = 0; foreach ($s in $scores) { $total += $s }
Write-Output "得分: $total/100"
foreach ($r in $reasons) { Write-Output "  $r" }
if ($total -ge 70) { exit 0 } else { exit 1 }
