# ============================================================
# 8LINK 拡張機能セットアップ・ブートストラップ(スタッフPC用)
# 管理者PowerShellで:
#   Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/nurunuru2022-coder/8link-ext-dist/main/bootstrap.ps1 | iex
# やること: git/gh導入→GitHubログイン(ブラウザ)→リポクローン→自動更新タスク登録
# ============================================================
$ErrorActionPreference = "Stop"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "管理者PowerShellで実行してください(スタート右クリック→ターミナル(管理者))" -ForegroundColor Red
  return
}

# 1) git / gh の導入(無ければwingetで入れる)
foreach ($t in @(@{cmd="git";id="Git.Git"}, @{cmd="gh";id="GitHub.cli"})) {
  if (-not (Get-Command $t.cmd -ErrorAction SilentlyContinue)) {
    Write-Host "$($t.cmd) をインストールします..." -ForegroundColor Cyan
    winget install --id $t.id -e --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
  }
}

# 2) GitHubログイン(未ログインならブラウザ認証が開く)
# 注意: PS5.1では未ログイン時のstderr出力が$ErrorActionPreference=Stopと衝突して
# スクリプトが落ちるため、この判定だけ一時的にエラーを無視して$LASTEXITCODEで見る
$eap = $ErrorActionPreference; $ErrorActionPreference = "SilentlyContinue"
& gh auth status *> $null
$ErrorActionPreference = $eap
if ($LASTEXITCODE -ne 0) {
  Write-Host "GitHubにログインします。ブラウザが開いたら nurunuru2022-coder でログインしてください" -ForegroundColor Cyan
  gh auth login --hostname github.com --git-protocol https --web
}
gh auth setup-git

# 3) リポジトリのclone/pull
New-Item -ItemType Directory -Force C:\dev | Out-Null
$repos = @("8link-company-os","prista-tool","crossma-tool","selsuma-automation")
foreach ($r in $repos) {
  if (Test-Path "C:\dev\$r\.git") {
    git -C "C:\dev\$r" pull --ff-only
  } else {
    git clone "https://github.com/nurunuru2022-coder/$r" "C:\dev\$r"
  }
}

# 4) 自動更新セットアップ(旧レジストリ掃除＋30分ごとpullタスク)
powershell -ExecutionPolicy Bypass -File C:\dev\8link-company-os\tools\setup-ext-all.ps1

Write-Host ""
Write-Host "================= 仕上げ(手作業) =================" -ForegroundColor Yellow
Write-Host "chrome://extensions を開き、このPCで使う拡張だけを読み込んでください:"
Write-Host "  1. 右上「デベロッパーモード」をON"
Write-Host "  2. 旧い拡張(Desktop/Downloads等のフォルダから読込済みのもの)があれば、"
Write-Host "     先にオプション画面の設定値(GAS URL/トークン等)を控えてから「削除」"
Write-Host "  3. 「パッケージ化されていない拡張機能を読み込む」で必要な分だけ選択:"
Write-Host "     クロスマ: C:\dev\crossma-tool\extension"
Write-Host "     セルスマ: C:\dev\selsuma-automation\extension"
Write-Host "     プリスタ: C:\dev\prista-tool\extension"
Write-Host "  4. 控えた設定値を新しい拡張のオプション画面へ入れ直す"
Write-Host "以後の更新は全自動です(30分ごとpull＋拡張が10分ごとに自動リロード)"
