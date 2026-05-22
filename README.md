# QUICK_SETUP_AIF

Azure AI Foundry と GPT 最新モデルを **1クリック** でデプロイできるテンプレートです。

## Deploy to Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhihirata-eng%2Fquick_setup_aif%2Fmain%2Farm%2Fazuredeploy.json)

## デプロイされるリソース

| リソース | 説明 |
|---|---|
| Azure OpenAI Service | GPT-5.2以上のモデルをチェックボックスで選択してデプロイ（デフォルト: gpt-5.4）|
| Azure AI Hub | AI Foundry のハブリソース |
| Azure AI Project | AI Foundry のプロジェクト |
| Storage Account | AI Hub の依存リソース |
| Key Vault | AI Hub の依存リソース |
| Container Registry | AI Hub の依存リソース |
| Application Insights | AI Hub の依存リソース |

## パラメータ

| パラメータ | デフォルト値 | 説明 |
|---|---|---|
| `prefix` | `aif` | リソース名のプレフィックス（3〜8文字） |
| `gptDeploymentCapacity` | `10` | TPM キャパシティ（千単位、モデルごと共通） |

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
│       └── bicep-to-arm.yml   # Bicep → ARM 変換 CI/CD
├── bicep/
│   ├── main.bicep             # メインテンプレート
│   └── modules/
│       ├── openai.bicep       # Azure OpenAI + GPT デプロイ
│       ├── ai-hub.bicep       # Azure AI Hub
│       ├── ai-project.bicep   # Azure AI Project
│       ├── storage.bicep      # ストレージアカウント
│       ├── keyvault.bicep     # Key Vault
│       ├── container-registry.bicep
│       └── app-insights.bicep
└── arm/
    └── azuredeploy.json       # 自動生成 ARM テンプレート
```

## 開発フロー

1. `bicep/` 配下の Bicep ファイルを編集
2. `main` ブランチへ push
3. GitHub Actions が自動的に `arm/azuredeploy.json` を生成・コミット

## 前提条件

- Azure サブスクリプション
- デプロイ先リージョンで Azure OpenAI Service の利用が承認済みであること
- 選択したモデルに対する十分なクォータ（デフォルト: 10K TPM）

## 注意事項

- GPT-5系モデルのクォータはリージョンやサブスクリプションのティアによって制限があります。`gptDeploymentCapacity` パラメータで調整してください。
- AI Foundry (Hub/Project) は East US、West Europe など[対応リージョン](https://learn.microsoft.com/azure/ai-studio/reference/region-support)でのみ利用可能です。
