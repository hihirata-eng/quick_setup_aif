# AGENTS.md

このファイルは、AIエージェント（GitHub Copilot など）がこのリポジトリで作業する際に従うべき規則と設計方針をまとめたものです。

---

## 1. Git コミットメッセージ規則

**Conventional Commits** 形式を使用する。

```
<type>(<scope>): <summary>

[body]

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### type の選択基準

| type | 使用場面 |
|---|---|
| `feat` | 新機能の追加（新モジュール、新パラメータなど） |
| `fix` | バグ修正（ビルドエラー、ARM 生成の誤りなど） |
| `refactor` | 機能変更なしの構造変更（リネーム、モジュール分割） |
| `docs` | README・AGENTS.md などドキュメントのみの変更 |
| `chore` | ビルドプロセス・CI/CD・ツール設定の変更 |
| `ci` | GitHub Actions ワークフローの変更 |

### scope の例

`bicep`, `arm`, `ci`, `readme`, `modules`

### 規則

- summary は **英語・命令形・小文字始まり・末尾ピリオドなし**
- body は変更の意図・背景を記述（日本語可）
- **コミット前に必ず `bicep build` でエラーなしを確認すること**
- `arm/azuredeploy.json` は自動生成ファイルのため、Bicep 変更時は常に一緒にコミットする
- `RFP.md` は `.gitignore` で除外済み。コミットしないこと

---

## 2. Bicep 設計方針

### 全体構造

```
bicep/
  main.bicep          # エントリポイント。パラメータ定義・モジュール呼び出しのみ
  modules/
    ai-services.bicep       # Azure AI Services (kind: AIServices)
    ai-hub.bicep            # Azure Machine Learning Hub (AI Foundry)
    ai-project.bicep        # AI Foundry Project
    storage.bicep           # Storage Account
    keyvault.bicep          # Key Vault
    container-registry.bicep # Container Registry
    app-insights.bicep      # Application Insights + Log Analytics
arm/
  azuredeploy.json    # Bicep から自動生成。直接編集禁止
```

### リソース命名（Microsoft CAF 推奨略称）

リソースごとに `{略称}{uniqueSuffix}` の形式を使用する。`uniqueSuffix` は `resourceGroup().id` から6文字を生成。

| リソース | 略称 | 例 |
|---|---|---|
| Azure AI Services | `ais-` | `ais-abc123` |
| Storage Account | `st` | `stabc123`（ハイフンなし） |
| Key Vault | `kv-` | `kv-abc123` |
| Container Registry | `cr` | `crabc123`（ハイフンなし） |
| Application Insights | `appi-` | `appi-abc123` |
| Log Analytics Workspace | `log-` | `log-abc123` |
| AI Hub | `aih-` | `aih-abc123` |
| AI Project | `aip-` | `aip-abc123` |

参考: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

### Location

- `location` パラメータは**設けない**。`var location = resourceGroup().location` で固定。
- ユーザーにリージョンを2箇所指定させる UX を避けるため。

### タグ

```bicep
var tags = {
  project: 'quick-setup-aif'
  createdBy: 'bicep'
}
```

すべてのモジュールに `tags` を渡すこと。

---

## 3. Azure AI Services 設計方針

### kind: 'AIServices' を使用する

- `kind: 'OpenAI'`（旧来の単独 Azure OpenAI Service）は**使用しない**
- `kind: 'AIServices'` は AI Foundry ネイティブのマルチサービスアカウント（OpenAI + Speech + Content Safety 統合）
- Azure AI Hub との接続は `aiServicesId`（リソースID）と `aiServicesTarget`（エンドポイントURL）を使用する

参考: https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.machinelearningservices/aifoundry-basics

### モデルデプロイ

- 対象モデルは **GPT-5.2 以上** に限定する（gpt-4o 等の旧モデルは追加しない）
- ユーザーが複数モデルをチェックボックスで選択できるよう、各モデルに `bool` パラメータを用意する
- デフォルトは `deployGpt54 = true` のみ
- `Microsoft.CognitiveServices/accounts/deployments` の並列デプロイは不可。**必ず `dependsOn` で直列化**すること

```bicep
// 直列化の例
resource dep54 '...deployments...' = if (deployGpt54) {
  dependsOn: [dep55]
  ...
}
```

### モデルバージョン追加時の規則

新モデルを追加する場合:
1. `ai-services.bicep` に `bool` パラメータと `deployment` リソースを追加（`dependsOn` チェーンを維持）
2. `main.bicep` の `aiServices` モジュール呼び出しにパラメータを追加
3. `README.md` のモデル選択表を更新
4. `bicep build` でエラーなし確認後にコミット

---

## 4. GitHub Actions

`.github/workflows/bicep-to-arm.yml` は `bicep/**` への push をトリガーに ARM テンプレートを自動生成してコミットする。

- ワークフローファイルのプッシュには `workflow` スコープが必要
- `gh auth refresh -h github.com -s workflow` でスコープを付与してからプッシュすること

---

## 5. README 更新ルール

以下の変更を行った場合は、`README.md` の対応箇所も同じコミットで更新すること。

| 変更内容 | README の更新箇所 |
|---|---|
| モデル追加・削除 | 「デプロイされるリソース > モデル選択」の表 |
| リソース種別の変更 | 「デプロイされるリソース」の説明 |
| リポジトリ所有者の変更 | Deploy to Azure ボタンの URL |
| パラメータの追加・変更 | 「カスタマイズ可能なパラメータ」セクション |
