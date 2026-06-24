# QUICK_SETUP_AIF

Azure AI Foundry と GPT 最新モデルを **1クリック** でデプロイできるテンプレートです。

## Deploy to Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhihirata-eng%2Fquick_setup_aif%2Fmain%2Farm%2Fazuredeploy.json)

## デプロイされるリソース

| リソース | 説明 |
|---|---|
| Azure AI Services | AI Foundry ネイティブのマルチサービスアカウント（OpenAI + Speech + Content Safety 統合）。GPT-5.2以上のモデルをチェックボックスで選択してデプロイ（デフォルト: gpt-5.4）|
| Azure AI Hub | AI Foundry のハブリソース |
| Azure AI Project | AI Foundry のプロジェクト |
| Storage Account | AI Hub の依存リソース |
| Key Vault | AI Hub の依存リソース |
| Container Registry | AI Hub の依存リソース |
| Application Insights | AI Hub の依存リソース |

## パラメータ

| パラメータ | デフォルト値 | 説明 |
|---|---|---|
| `userObjectId` | `""` | ロール割り当てを付与する Microsoft Entra ID ユーザーのオブジェクト ID。空の場合はロール割り当てをスキップ |
| `gptDeploymentCapacity` | `10` | TPM キャパシティ（千単位、モデルごと共通） |

> リソース名は [Microsoft 推奨の省略形](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) + ユニークサフィックスで自動生成されます（例: `oai-xxxxxx`, `kv-xxxxxx`）。

> **Location** はリソースグループのリージョンを自動使用します。選択不要です。

### デプロイするモデルを選択（チェックボックス）

複数同時にデプロイ可能です。

| パラメータ | デフォルト | モデル | バージョン | 特徴 |
|---|---|---|---|---|
| `deployGpt55` | ☐ | `gpt-5.5` | 2026-04-24 | 最新・最高性能 |
| `deployGpt54` | ✅ | `gpt-5.4` | 2026-03-05 | 高性能・推論対応 |
| `deployGpt54pro` | ☐ | `gpt-5.4-pro` | 2026-03-05 | プロ版 |
| `deployGpt54mini` | ☐ | `gpt-5.4-mini` | 2026-03-17 | 軽量版 |
| `deployGpt54nano` | ☐ | `gpt-5.4-nano` | 2026-03-17 | 超軽量版 |
| `deployGpt53codex` | ☐ | `gpt-5.3-codex` | 2026-02-24 | コーディング特化 |
| `deployGpt52` | ☐ | `gpt-5.2` | 2025-12-11 | 高性能 |
| `deployGpt52codex` | ☐ | `gpt-5.2-codex` | 2026-01-14 | コーディング特化 |

## ディレクトリ構成

```
.
├── .github/
│   └── workflows/
│       └── bicep-to-arm.yml      # Bicep → ARM 変換 CI/CD
├── bicep/
│   ├── main.bicep                # メインテンプレート（パラメータ定義・モジュール呼び出し）
│   └── modules/
│       ├── ai-services.bicep     # Azure AI Services (kind: AIServices) + GPT デプロイ
│       ├── ai-hub.bicep          # Azure AI Hub
│       ├── ai-project.bicep      # Azure AI Project
│       ├── storage.bicep         # ストレージアカウント
│       ├── keyvault.bicep        # Key Vault
│       ├── container-registry.bicep
│       └── app-insights.bicep    # Application Insights + Log Analytics
├── arm/
│   └── azuredeploy.json          # 自動生成 ARM テンプレート（直接編集禁止）
├── AGENTS.md                     # AIエージェント向けプロジェクト規則
└── .gitignore
```

## 前提条件

- Azure サブスクリプション
- デプロイ先リージョンで Azure AI Services の利用が承認済みであること
- 選択したモデルに対する十分なクォータ（デフォルト: 10K TPM）

## 注意事項

- GPT-5系モデルのクォータはリージョンやサブスクリプションのティアによって制限があります。`gptDeploymentCapacity` パラメータで調整してください。
- AI Foundry (Hub/Project) は East US、West Europe など[対応リージョン](https://learn.microsoft.com/azure/ai-studio/reference/region-support)でのみ利用可能です。

---

## メンテナ向け

### 開発環境セットアップ

```bash
# Bicep CLI のインストール（az bicep install が SSL エラーになる場合）
curl -k -Lo /tmp/bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
chmod +x /tmp/bicep

# ビルド確認
/tmp/bicep build bicep/main.bicep --outfile arm/azuredeploy.json
```

### 開発フロー

```
[Bicep 編集] → [ローカルビルド確認] → [commit & push to main]
                                              ↓
                                   GitHub Actions が自動実行
                                   az bicep build → azuredeploy.json 更新
                                   → 自動コミット（[ci skip] なし）
```

1. `bicep/` 配下を編集
2. **必ず** `/tmp/bicep build bicep/main.bicep` でエラーなしを確認してからコミット
3. `main` ブランチへ push → GitHub Actions が `arm/azuredeploy.json` を自動更新
4. `arm/azuredeploy.json` は自動生成ファイルのため**直接編集しない**

### コミット規則

[Conventional Commits](https://www.conventionalcommits.org/) を使用する。詳細は [AGENTS.md](./AGENTS.md) を参照。

```
feat(bicep): add gpt-5.6 model deployment option
fix(modules): correct dependsOn chain in ai-services
refactor(bicep): rename openai module to ai-services
docs: update README model table
ci: bump bicep-to-arm workflow to bicep 0.44
```

### リソース命名規則

[Microsoft CAF 推奨の省略形](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)を使用する。

| リソース | 略称 | 例 |
|---|---|---|
| Azure AI Services | `ais-` | `ais-abc123` |
| Storage Account | `st` | `stabc123` |
| Key Vault | `kv-` | `kv-abc123` |
| Container Registry | `cr` | `crabc123` |
| Application Insights | `appi-` | `appi-abc123` |
| Log Analytics Workspace | `log-` | `log-abc123` |
| AI Hub | `aih-` | `aih-abc123` |
| AI Project | `aip-` | `aip-abc123` |

### モデルを追加・更新する手順

1. `bicep/modules/ai-services.bicep` に `bool` パラメータと `deployment` リソースを追加する
   - `dependsOn` のチェーンに組み込むこと（並列デプロイ不可）
2. `bicep/main.bicep` の `aiServices` モジュール呼び出しに新パラメータを追加する
3. `README.md` のモデル選択表を更新する
4. ビルド確認 → コミット → push

> **方針**: 対象モデルは **GPT-5.2 以上** に限定する。gpt-4o 等の旧世代モデルは追加しない。

### Azure AI Services について

このテンプレートでは `kind: 'AIServices'`（AI Foundry ネイティブ）を使用している。

- `kind: 'OpenAI'`（旧来の単独 Azure OpenAI Service）は**使用しない**
- AI Hub との接続には `aiServicesId`（リソースID）と `aiServicesTarget`（エンドポイントURL）を使用する
- 参考: [Azure Quickstart Templates - AI Foundry Basics](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.machinelearningservices/aifoundry-basics)

### GitHub Actions のスコープ

ワークフローファイル（`.github/workflows/`）を push するには `workflow` スコープが必要。

```bash
gh auth refresh -h github.com -s workflow
```
