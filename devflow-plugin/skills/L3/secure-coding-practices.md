---
name: secure-coding-practices
description: "安全编码规范。覆盖通用安全编码准则和语言特定规范（JavaScript/TypeScript/Python/Go），映射 OWASP Top 10 漏洞模式和修复指南。被 coding-stage-execution 调用。"
---

# Secure Coding Practices（安全编码规范）

## 定位

本技能为 Step 3 编码阶段提供安全编码规范，覆盖通用安全编码准则和语言特定规范（JavaScript/TypeScript、Python、Go），映射 OWASP Top 10 漏洞模式和修复指南，帮助开发人员在编码过程中防止常见安全漏洞。

本技能不替代设计阶段的安全设计评审（由 `security-design-review` 负责），也不替代正式的安全扫描工具。它负责为开发人员提供编码层面的安全实践指导，确保代码实现满足安全要求。

推荐位置：

```text
Step 3 编码实现 → 遵循 project-coding-conventions → 遵循 secure-coding-practices → code-static-quality-check → 开发自测
```

## 触发条件

当以下场景发生时，应调用本技能：

- 编码阶段编写涉及安全的功能（认证、授权、加密、数据处理）时
- 处理用户输入（表单、URL 参数、请求体、文件上传）时
- 使用密码学功能（加密、哈希、签名、随机数生成）时
- 调用外部服务或第三方 API 时
- 代码审查中检查安全问题时
- 安全扫描发现漏洞需要修复时

## 通用安全编码准则

### 输入验证

所有外部输入（用户输入、API 参数、文件上传、环境变量、配置文件）必须经过验证。

| 验证策略 | 说明 | 示例 |
|---|---|---|
| 白名单验证 | 只允许已知的合法值，拒绝其他所有输入 | 允许的文件类型白名单：["jpg", "png", "pdf"] |
| 类型检查 | 验证输入数据的类型是否符合预期 | age 必须为正整数，name 必须为字符串 |
| 长度限制 | 对字符串、数组、文件等设置合理的长度上限 | 用户名 4-32 字符，评论内容最多 1000 字 |
| 格式验证 | 对邮箱、手机号、URL 等使用正则或标准库验证 | 使用库函数验证邮箱格式，不手写正则 |
| 范围检查 | 对数值类型验证合法范围 | 金额 > 0 且 <= 999999.99 |

### 输出编码

根据输出上下文使用适当的编码方式，防止注入攻击。

| 输出上下文 | 编码方式 | 说明 |
|---|---|---|
| HTML 内容 | HTML 实体编码 | 将 `<` 转为 `&lt;`，`>` 转为 `&gt;` 等 |
| HTML 属性 | HTML 属性编码 | 除实体编码外，对引号进行编码 |
| JavaScript | JS 编码 | 防止通过 DOM 注入恶意脚本 |
| URL | URL 编码 | 对特殊字符进行百分比编码 |
| CSS | CSS 编码 | 防止通过 CSS 注入执行脚本 |
| SQL | 参数化查询 | 使用参数绑定而非字符串拼接 |

### 认证安全

| 安全要求 | 说明 | 实践 |
|---|---|---|
| 密码哈希 | 永远不存储明文密码 | 使用 bcrypt（cost factor >= 12）或 argon2id |
| 多因子认证 | 敏感操作需二次验证 | 支持 TOTP、SMS 或硬件令牌 |
| 账户锁定 | 防止暴力破解 | 连续 5 次失败锁定 15 分钟，支持验证码解锁 |
| 安全传输 | 认证凭据必须加密传输 | 密码、令牌等仅通过 HTTPS 传输 |
| 令牌安全 | 访问令牌和刷新令牌分离 | 访问令牌短有效期（15 分钟），刷新令牌长有效期但可撤销 |

### 授权检查

| 安全要求 | 说明 |
|---|---|
| 每个请求验证权限 | 不能仅依赖前端隐藏，后端每个接口必须独立校验权限 |
| 权限最小化 | 只授予完成任务所需的最小权限集 |
| 越权检查 | 水平越权（访问同级别其他用户数据）和垂直越权（访问高权限功能）都必须检查 |
| 资源归属验证 | 修改/删除操作必须验证当前用户是否为资源所有者或授权人 |

### 密码学使用

| 安全要求 | 说明 |
|---|---|
| 不自行实现加密 | 使用经过广泛验证的标准库，禁止自研加密算法 |
| 使用标准库 | 加密用 AES-256-GCM，哈希用 SHA-256+，签名用 RS256/ES256 |
| 密钥管理 | 密钥存储在密钥管理服务（KMS/Vault）中，禁止硬编码在代码里 |
| 安全随机数 | 使用密码学安全的随机数生成器（CSPRNG），禁止使用 Math.random() 生成安全相关值 |
| 算法选择 | 使用最新推荐算法，禁用 MD5、SHA1、DES、RC4 等已废弃算法 |

### 错误处理

| 安全要求 | 说明 |
|---|---|
| 不泄露堆栈信息 | 生产环境错误响应不包含堆栈跟踪、内部路径、数据库信息 |
| 统一错误码 | 使用预定义的错误码，错误消息不含敏感信息 |
| 日志记录安全事件 | 记录完整的错误详情到安全日志，但不暴露给用户 |
| 安全降级 | 发生安全相关错误时，默认拒绝而非默认允许 |

### 日志安全

| 安全要求 | 说明 |
|---|---|
| 不记录敏感信息 | 禁止在日志中记录密码、密钥、令牌、信用卡号等敏感数据 |
| 日志脱敏 | 必须记录的字段（如手机号、身份证号）进行脱敏处理 |
| 安全事件单独标记 | 认证失败、权限异常、注入攻击等安全事件使用特殊标记，便于告警 |
| 日志访问控制 | 限制日志访问权限，防止通过日志获取敏感信息 |

### 文件操作

| 安全要求 | 说明 |
|---|---|
| 路径遍历防护 | 使用规范化的绝对路径，检查路径是否在允许的目录范围内 |
| 上传文件限制 | 验证文件类型（Magic Number 而非仅扩展名）、大小，使用随机文件名 |
| 临时文件清理 | 处理完成后立即删除临时文件，避免残留敏感数据 |
| 下载安全 | 文件下载使用流式传输，不暴露服务器文件系统结构 |

## 语言特定安全编码规范

### JavaScript / TypeScript

#### XSS 防护

| 检查项 | 安全实践 | 不安全实践 |
|---|---|---|
| DOM 操作 | 使用 `textContent` 赋值，React 使用 `{}` 自动转义 | 使用 `innerHTML`、`dangerouslySetInnerHTML` |
| 框架保护 | React/Vue 默认转义输出，利用框架特性 | 绕过框架的自动转义机制 |
| CSP 配置 | 配置 Content-Security-Policy 限制脚本来源 | 不配置 CSP 或设置为过于宽松 |
| URL 处理 | 使用框架的路由和链接组件 | 直接拼接 URL 参数到 `href` 或 `src` |

```text
// 不安全 - 禁止
element.innerHTML = userInput
// 安全 - 使用 textContent
element.textContent = userInput
// React 中安全 - 自动转义
<p>{userInput}</p>
// React 中不安全 - 需确保数据已消毒
<p dangerouslySetInnerHTML={{ __html: sanitizedData }}</p>
```

#### Prototype Pollution 防护

| 检查项 | 安全实践 |
|---|---|
| 对象合并 | 使用 `Object.assign()` 或展开运算符，不使用递归合并用户输入 |
| 深拷贝 | 使用 `structuredClone()` 或安全库，不使用 `JSON.parse(JSON.stringify())` 处理不可信数据 |
| 输入检查 | 对 `__proto__`、`constructor`、`prototype` 等键名进行过滤或拒绝 |

#### 依赖安全

| 工具 | 用途 | 命令 |
|---|---|---|
| npm audit | 检查已知漏洞 | `npm audit` |
| Snyk | 持续漏洞扫描 | `snyk test` |
| lockfile | 锁定依赖版本 | 确保 package-lock.json 提交到版本库 |
| renovate | 自动依赖更新 | 集成 renovate bot 定期更新 |

#### Node.js 特有安全

| 检查项 | 安全实践 |
|---|---|
| child_process | 尽量避免使用，必须使用时禁止拼接用户输入到 shell 命令 |
| 事件循环 | 防止同步操作阻塞事件循环，导致拒绝服务 |
| 大文件处理 | 使用流式处理，不将大文件完整读入内存 |
| 依赖注入 | 避免使用 `require()` 或 `import()` 动态加载不可信路径的模块 |

### Python

#### 注入防护

| 注入类型 | 安全实践 | 不安全实践 |
|---|---|---|
| SQL 注入 | 使用参数化查询或 ORM | 使用字符串格式化拼接 SQL |
| 命令注入 | 使用 `subprocess.run(args_list)` 传递参数列表 | 使用 `os.system()`、`subprocess.run(cmd_string, shell=True)` |
| SSTI | 禁止在模板中执行用户输入的表达式 | 使用 `eval()`、`exec()` 处理模板变量 |
| LDAP 注入 | 使用参数化 LDAP 查询 | 拼接用户输入到 LDAP 过滤器 |

```text
# 不安全 - 禁止
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
# 安全 - 参数化查询
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

#### 序列化安全

| 检查项 | 安全实践 |
|---|---|
| pickle | 禁止反序列化不可信来源的 pickle 数据，使用 JSON 替代 |
| YAML | 使用 `yaml.safe_load()` 替代 `yaml.load()`，防止任意代码执行 |
| JSON | 使用标准 `json` 模块，注意自定义解码器的安全性 |

#### 依赖安全

| 工具 | 用途 | 命令 |
|---|---|---|
| pip audit | 检查已知漏洞 | `pip audit` |
| safety | 依赖安全检查 | `safety check` |
| pip-audit | 替代方案 | `pip-audit` |
| requirements.txt | 锁定依赖版本 | 使用 `pip freeze > requirements.txt` 并提交 |

#### Flask / Django 特有安全

| 检查项 | Flask | Django |
|---|---|---|
| CSRF 保护 | 启用 Flask-WTF 的 CSRF 保护 | 默认启用 `CsrfViewMiddleware` |
| 安全 Cookie | 设置 `SESSION_COOKIE_SECURE=True`、`SESSION_COOKIE_HTTPONLY=True` | 设置 `SESSION_COOKIE_SECURE=True` |
| Debug 模式 | 生产环境 `DEBUG=False` | 生产环境 `DEBUG=False` |
| 点击劫持 | 设置 `X-Frame-Options` 响应头 | 默认启用 `XFrameOptionsMiddleware` |
| 安全头 | 使用 flask-talisman | 使用 django-security 中间件 |

### Go

#### 并发安全

| 检查项 | 安全实践 |
|---|---|
| goroutine 泄露 | 确保 goroutine 有明确的退出条件，使用 `context.WithCancel` 控制生命周期 |
| 数据竞争 | 使用 `-race` 标志检测竞争，共享数据使用 `sync.Mutex` 或 channel 通信 |
| race detector | 测试和 CI 中使用 `go test -race` 检测数据竞争 |
| channel 使用 | 避免向已关闭的 channel 发送数据，确保 channel 消费者正确退出 |

#### 输入验证

| 检查项 | 安全实践 |
|---|---|
| regexp 防DoS | 用户输入用于正则表达式前验证格式，避免 ReDoS（正则拒绝服务）攻击 |
| 整数溢出 | 对数值输入使用 `int64` 或 `math/big`，检查溢出边界 |
| 字符串处理 | 使用 `utf8.ValidString()` 验证 UTF-8 编码，防止无效编码导致的问题 |

#### 依赖安全

| 工具 | 用途 | 命令 |
|---|---|---|
| govulncheck | 检查已知漏洞 | `govulncheck ./...` |
| nancy | 依赖漏洞扫描 | `nancy go.sum` |
| go.mod | 锁定依赖版本 | 使用 `go mod tidy` 维护，提交 go.sum |

## OWASP Top 10 映射表

以下是 OWASP Top 10 (2021) 漏洞类别与检测方法、修复指南的映射：

| 编号 | 漏洞名称 | 风险等级 | 检测方法 | 修复指南 | 代码示例 |
|---|---|---|---|---|---|
| A01 | Broken Access Control（失效的访问控制） | 严重 | 检查每个接口是否有权限校验；测试越权访问（IDOR） | 每个请求验证用户权限；资源操作验证归属关系；使用统一的权限中间件 | `if (user.id !== resource.ownerId) throw new ForbiddenError()` |
| A02 | Cryptographic Failures（加密机制失效） | 严重 | 审查加密算法选择；检查敏感数据是否明文存储/传输 | 使用 AES-256-GCM 加密；密码使用 bcrypt/argon2；强制 TLS 1.2+；密钥使用 KMS 管理 | `const hash = await bcrypt.hash(password, 12)` |
| A03 | Injection（注入） | 严重 | 检查是否存在字符串拼接 SQL/命令；使用静态分析工具扫描 | 使用参数化查询；使用 ORM；避免 `eval`/`exec`；对输出进行上下文编码 | `query("SELECT * FROM users WHERE id = ?", [userId])` |
| A04 | Insecure Design（不安全的设计） | 高 | 审查威胁模型；检查安全需求是否在设计中体现 | 执行威胁建模（STRIDE）；制定安全用户故事；实现安全反模式检查；采用纵深防御 | 在设计阶段引入 `security-design-review` |
| A05 | Security Misconfiguration（安全配置错误） | 高 | 审查默认配置；检查是否关闭 Debug 模式、是否暴露错误详情 | 关闭生产环境的调试模式和详细错误；移除默认凭据；禁用不必要的功能和端口；配置安全响应头 | `app.config['DEBUG'] = False` |
| A06 | Vulnerable and Outdated Components（易受攻击和过时的组件） | 高 | 执行依赖漏洞扫描（npm audit/pip audit/govulncheck）；检查依赖许可证 | 建立依赖更新流程；使用自动化工具持续扫描；及时升级有安全补丁的版本；锁定依赖版本 | `npm audit --production` |
| A07 | Identification and Authentication Failures（身份识别和认证失败） | 高 | 检查密码策略；检查会话管理；检查令牌安全性 | 实施强密码策略和 MFA；使用安全会话管理（HttpOnly/Secure Cookie）；令牌设置合理过期时间 | `session.cookie_httponly = True; session.cookie_secure = True` |
| A08 | Software and Data Integrity Failures（软件和数据完整性失败） | 中 | 检查 CI/CD 流水线安全；检查反序列化安全；验证依赖来源 | 使用可信的依赖源和包签名；禁止反序列化不可信数据；CI/CD 流水线使用签名和验证 | `yaml.safe_load(data)` 替代 `yaml.load(data)` |
| A09 | Security Logging and Monitoring Failures（安全日志和监控失败） | 中 | 检查安全事件是否被记录和告警；检查日志是否脱敏 | 记录认证失败、权限异常、输入验证失败等安全事件；配置实时告警；日志脱敏处理 | `logger.warn("SECURITY_EVENT: login_failed", { ip, userId })` |
| A10 | Server-Side Request Forgery (SSRF)（服务端请求伪造） | 中 | 检查服务端是否根据用户输入发起外部请求；检查 URL 白名单 | 对外部请求的目标地址实施白名单策略；禁止请求内网地址；限制协议（仅 HTTPS）；禁用重定向跟随 | `if (!ALLOWED_HOSTS.includes(url.hostname)) throw new Error("Blocked")` |

## 安全代码审查清单

以下审查清单覆盖九个安全维度，用于代码审查时逐项检查：

| 检查维度 | 检查要点 | 通过标准 |
|---|---|---|
| 输入验证 | 所有外部输入是否经过类型、长度、格式验证？是否使用白名单而非黑名单？ | 每个外部输入至少包含类型和长度验证 |
| 输出编码 | 动态内容输出是否根据上下文（HTML/URL/JS/CSS）正确编码？ | 所有动态输出使用框架自动转义或手动编码 |
| 认证授权 | 每个接口是否校验用户身份和权限？是否存在越权风险？ | 100% 接口有权限校验，IDOR 场景验证资源归属 |
| 密码学使用 | 是否使用标准加密算法？密码是否正确哈希？密钥是否安全存储？ | 无自研加密，密码使用 bcrypt/argon2，无硬编码密钥 |
| 错误处理 | 生产错误响应是否泄露堆栈/内部信息？安全错误是否默认拒绝？ | 错误响应不含敏感信息，安全相关错误默认拒绝 |
| 日志安全 | 日志是否记录敏感信息？安全事件是否标记？日志访问是否受限？ | 敏感信息已脱敏，安全事件有标记，日志访问有权限控制 |
| 文件操作 | 是否防范路径遍历？上传文件类型和大小是否限制？临时文件是否清理？ | 使用绝对路径白名单，文件类型用 Magic Number 验证 |
| 依赖安全 | 是否有已知漏洞？依赖版本是否锁定？许可证是否合规？ | 无高危/严重漏洞，版本已锁定，许可证兼容 |
| 配置安全 | Debug 模式是否关闭？默认密码是否更改？不必要端口是否关闭？ | 生产环境 Debug 关闭，无默认凭据，最小化暴露面 |

## 反模式

以下是在安全编码中应避免的做法：

- **拼接 SQL**：使用字符串格式化或拼接构造 SQL 查询，直接导致 SQL 注入漏洞
- **硬编码密钥**：将密钥、密码、API Token 等直接写在代码中，导致凭据泄露
- **信任客户端输入**：不验证和清洗来自客户端（前端、API 调用方）的任何输入
- **忽略错误处理**：捕获异常后静默忽略，或在错误响应中暴露内部实现细节
- **使用废弃算法**：使用 MD5、SHA1、DES、RC4 等已被证明不安全的算法
- **禁用安全特性**：为开发方便关闭 CSRF 保护、XSS 防护、HSTS 等安全特性后忘记恢复
- **使用 eval/exec**：动态执行不可信的字符串内容，导致代码注入漏洞
- **不更新依赖**：长期不更新依赖包，保留已知安全漏洞不修复
- **绕过框架保护**：为了方便绕过框架内置的安全机制（如 React 的自动转义、Django 的 CSRF 保护）

## 强制规则

以下规则必须严格遵守：

1. 所有用户输入必须经过验证和编码，不允许未经验证的输入直接用于 SQL 查询、命令执行或页面输出
2. 用户密码必须使用 bcrypt（cost factor >= 12）或 argon2id 进行哈希存储，禁止明文存储
3. 禁止在代码中使用 `eval()`、`exec()`、`Function()` 等动态执行不可信字符串的函数
4. 禁止在代码中硬编码密钥、密码、API Token 等敏感凭据，必须使用环境变量或密钥管理服务
5. 所有数据库操作必须使用参数化查询或 ORM，禁止 SQL 字符串拼接
6. 生产环境必须关闭 Debug 模式，错误响应不得包含堆栈跟踪或内部信息
7. 日志中禁止记录密码、密钥、完整令牌等敏感信息，必须脱敏处理
8. 文件上传必须验证文件类型（Magic Number）、限制文件大小、使用随机文件名存储
9. 每个对外暴露的 API 接口必须校验用户身份和操作权限

## 变更记录

| 日期 | 变更内容 | 变更人 |
|---|---|---|
| 2026-07-02 | 初始版本，VR-007 安全开发全流程技能 - 安全编码规范部分 | DevFlow Team |
