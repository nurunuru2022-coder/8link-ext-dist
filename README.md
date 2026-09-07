# 8link-ext-dist

社内Chrome拡張の更新シグナル置き場(version.json)。
各PCの拡張(パッケージ化されていない拡張として C:\dev\<リポ>\extension を読込)が
1時間ごとにここのversion.jsonを確認し、自分のバージョンと違えばディスクから自動リロードする。
ディスク側は各PCのタスクスケジューラ(30分ごとgit pull)が最新化する。

リリースは 8link-company-os/tools/ext-release.ps1 -Name <名前> から(手で編集しない)。
台帳は 8link-company-os/tools/ext-registry.json。

- prista/ … prista-tool
- crossma/ … crossma-tool
- selsuma/ … selsuma-automation

(過去にCRX+ExtensionInstallForcelist方式を試したが、非管理PCではChromeが
ストア外強制インストールをブロックするため2026-09-07にこの方式へ変更)
