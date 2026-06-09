// マスクタイプボタンのトグル動作
window.addEventListener("DOMContentLoaded", function() {
  const btnIds = ["btn-jwt", "btn-awskey", "btn-custom", "btn-email", "btn-ipv4", "btn-entropy", "btn-url"];
  btnIds.forEach(id => {
    const btn = document.getElementById(id);
    if (btn) {
      btn.addEventListener("click", function() {
        btn.classList.toggle("active");
      });
    }
  });
});
const rules = [

  // IPv4
  {
    name: "IPv4",
    regex: /\b(?:\d{1,3}\.){3}\d{1,3}\b/g,
    replace: "xxxxxxx",
    color: "#8e24aa", // 紫
    class: "mask-ipv4"
  },

  // Email
  {
    name: "Email",
    regex: /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/g,
    replace: "xxxxxxx",
    color: "#fbc02d", // 黄
    class: "mask-email"
  },

  // URL
  {
    name: "URL",
    regex: /https?:\/\/[^\s]+/g,
    replace: "xxxxxxx",
    color: "#6d4c41", // 茶
    class: "mask-url"
  },

  // AWS Access Key
  {
    name: "AWS Access Key",
    regex: /AKIA[0-9A-Z]{16}/g,
    replace: "xxxxxxx",
    color: "#1e88e5", // 青
    class: "mask-awskey"
  },

  // JWT
  {
    name: "JWT",
    regex: /eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+/g,
    replace: "xxxxxxx",
    color: "#e53935", // 赤
    class: "mask-jwt"
  },

  // Bearer Token
  {
    name: "Bearer Token",
    regex: /Bearer\s+[A-Za-z0-9\-._~+/]+=*/gi,
    replace: "xxxxxxx",
    color: "#222",
    class: "mask-bearer"
  },

  // Cookie
  {
    name: "Cookie",
    regex: /(cookie\s*:\s*)(.+)/gi,
    replace: "xxxxxxx",
    color: "#43a047",
    class: "mask-cookie"
  },

  // Authorization Header
  {
    name: "Authorization",
    regex: /(authorization\s*:\s*)(.+)/gi,
    replace: "xxxxxxx",
    color: "#222",
    class: "mask-auth"
  },

  // Generic Secrets
  {
    name: "Generic Secret",
    regex: /((password|passwd|pwd|secret|secret_key|apikey|api_key|token|access_token|refresh_token|client_secret|private_key)\s*[=:]\s*)(.+)/gi,
    replace: "xxxxxxx",
    color: "#00bcd4",
    class: "mask-generic"
  },

  // JSON style secrets
  {
    name: "JSON Secret",
    regex: /("(password|secret|token|apikey|api_key|client_secret|private_key)"\s*:\s*")([^"]+)"/gi,
    replace: "xxxxxxx",
    color: "#00bcd4",
    class: "mask-json"
  },

  // .env style
  {
    name: ".env Secret",
    regex: /^([A-Z0-9_]*(PASSWORD|SECRET|TOKEN|API_KEY)[A-Z0-9_]*=)(.+)$/gim,
    replace: "xxxxxxx",
    color: "#00bcd4",
    class: "mask-env"
  },

  // PEM Private Key
  {
    name: "Private Key",
    regex: /-----BEGIN PRIVATE KEY-----[\s\S]+?-----END PRIVATE KEY-----/g,
    replace: "xxxxxxx",
    color: "#222",
    class: "mask-pem"
  },

  // Credit Card
  {
    name: "Credit Card",
    regex: /\b(?:\d[ -]*?){13,16}\b/g,
    replace: "xxxxxxx",
    color: "#ffb84f",
    class: "mask-cc"
  }

];

const exclude_rules = [
  // datetime
  {
    name: "Datetime",
    regex: /\b\d{4}[-/]\d{1,2}[-/]\d{1,2}[ T]\d{1,2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?\b/g,
  },
  {
    name: "Credit Card",
    regex: /\b(?:\d[ -]*?){13,16}\b/g,
  }

];

const inputText =
  document.getElementById("inputText");

const outputText =
  document.getElementById("outputText");

const keywordInput =
  document.getElementById("keywordInput");

const saveKeywordsButton =
  document.getElementById("saveKeywordsButton");

const showKeywordsButton =
  document.getElementById("showKeywordsButton");

const clearKeywordsButton =
  document.getElementById("clearKeywordsButton");

let customKeywords = [];

let keywordsVisible = false;

function escapeRegex(str) {

  return str.replace(
    /[.*+?^${}()|[\]\\]/g,
    "\\$&"
  );
}

function loadKeywords() {

  const saved =
    localStorage.getItem("custom_dictionary");

  if (!saved) {

    customKeywords = [];

    return;
  }

  try {

    customKeywords = JSON.parse(saved);

  } catch (e) {

    console.error(e);

    customKeywords = [];
  }
}




function maskCustomKeywords(text) {
  let result = text;
  let count = 0;
  for (const keyword of customKeywords) {
    console.log("Masking with keyword:", keyword);
    if (!keyword) continue;
    const regex = new RegExp(
      escapeRegex(keyword["keyword"]),
      "gu"
    );
    const before = result;
    result = result.replace(regex, function(match) {
      count++;
      return "xxxxxxx";
    });
  }
  return { result, count };
}


function checkExcludeRules(text) {

  for (const rule of exclude_rules) {

    // lastIndexリセット（gフラグ対策）
    rule.regex.lastIndex = 0;

    const result = rule.regex.exec(text);

    if (result) {
      return {
        matched: true,
        rule: rule.name,
        matchText: result[0]
      };
    }
  }

  return {
    matched: false,
    rule: null,
    matchText: null
  };
}

function calculateEntropy(str) {

  if(checkExcludeRules(str).matched)
  {
    return 0;
  }

  const map = {};

  for (const char of str) {
    map[char] = (map[char] || 0) + 1;
  }

  let entropy = 0;

  const length = str.length;

  for (const char in map) {

    const p = map[char] / length;

    entropy -= p * Math.log2(p);
  }

  return entropy;
}

function getEntropyMinValue() {
  // スライダーまたは数値入力から値を取得
  const slider = document.getElementById("entropyMin");
  const number = document.getElementById("entropyMinNumber");
  if (slider && number) {
    // どちらかの値を返す（同期されている想定）
    return parseFloat(slider.value) || 3.5;
  }
  return 3.5;
}

function maskHighEntropyStrings(text, countedEntropy) {
  const regex = /[A-Za-z0-9+/_\-=\.:]{20,}/g;
  const entropyMin = getEntropyMinValue();
  let count = countedEntropy;
  const result = text.replace(regex, (match) => {
    const hasLetter = /[A-Za-z]/.test(match);
    const hasNumber = /\d/.test(match);
    if (!hasLetter || !hasNumber) {
      return match;
    }
    const entropy = calculateEntropy(match);
    if (entropy > entropyMin) {
      count++;
      return "xxxxxxx";
    }
    return match;
  });
  return { result, count };
}

// エントロピー最小値コントロールの同期処理
window.addEventListener("DOMContentLoaded", function() {
  const slider = document.getElementById("entropyMin");
  const number = document.getElementById("entropyMinNumber");
  if (slider && number) {
    // スライダー変更時に数値入力を更新
    slider.addEventListener("input", function() {
      number.value = slider.value;
    });
    // 数値入力変更時にスライダーを更新
    number.addEventListener("input", function() {
      let val = parseFloat(number.value);
      if (isNaN(val)) val = 3.5;
      if (val < 1) val = 1;
      if (val > 6) val = 6;
      slider.value = val;
      number.value = val;
    });
  }
});



// テキストとHTML両方返すバージョン
function maskText(text) {
  let result = text;
  let htmlResult = text;
  let counts = {
    email: 0,
    api: 0,
    custom: 0,
    other: 0
  };

  // ボタンのactive状態を取得
  const isActive = {
    jwt: document.getElementById("btn-jwt")?.classList.contains("active"),
    awskey: document.getElementById("btn-awskey")?.classList.contains("active"),
    custom: document.getElementById("btn-custom")?.classList.contains("active"),
    email: document.getElementById("btn-email")?.classList.contains("active"),
    ipv4: document.getElementById("btn-ipv4")?.classList.contains("active"),
    entropy: document.getElementById("btn-entropy")?.classList.contains("active"),
    url: document.getElementById("btn-url")?.classList.contains("active"),
  };

  // カスタム辞書
  if (!isActive.custom) {
    const customRes = maskCustomKeywords(result);
    result = customRes.result;
    // HTML用も同じ置換（緑色）
    if (customKeywords.length > 0) {
      htmlResult = htmlResult.replace(
        new RegExp(customKeywords.map(k => escapeRegex(k.keyword)).join('|'), 'gu'),
        function(match) {
          return '<span class="masked-highlight mask-custom" style="background:#43a047;color:#fff;">xxxxxxx</span>';
        }
      );
    }
    counts.custom = customRes.count;
  }

  // エントロピー検出（カウント対象外）
  var countedEntropy = 0;
  if (!isActive.entropy)
  {
    // テキスト用

    result_array = maskHighEntropyStrings(result,countedEntropy);

    result = result_array["result"];
    countedEntropy = result_array["count"];
    // HTML用（シアン色）
    htmlResult = htmlResult.replace(/[A-Za-z0-9+/_\-=\.:]{20,}/g, (match) => {
      const hasLetter = /[A-Za-z]/.test(match);
      const hasNumber = /\d/.test(match);
      if (!hasLetter || !hasNumber) return match;
      const entropy = calculateEntropy(match);
      if (entropy > getEntropyMinValue()) {
        return '<span class="masked-highlight mask-entropy" style="background:#00bcd4;color:#fff;">xxxxxxx</span>';
      }
      return match;
    });
  }

  // 通常ルール
  for (const rule of rules) {
    let matchCount = 0;
    // ルールごとにactive判定
    if (
      (rule.name === "JWT" && isActive.jwt) ||
      (rule.name === "AWS Access Key" && isActive.awskey) ||
      (rule.name === "Custom" && isActive.custom) ||
      (rule.name === "Email" && isActive.email) ||
      (rule.name === "IPv4" && isActive.ipv4) ||
      (rule.name === "URL" && isActive.url)
    ) {
      continue;
    }
    result = result.replace(rule.regex, function(match) {
      matchCount++;
      return rule.replace;
    });
    // HTML用: マスク部分をspanでラップ（色分け）
      htmlResult = htmlResult.replace(rule.regex, function(match) {
      return `<span class="masked-highlight ${rule.class}" style="background:${rule.color};color:#fff;">${rule.replace}</span>`;
    });
    // カウント割り振り
    if (rule.name === "Email") {
      counts.email += matchCount;
    } else if (
      rule.name === "AWS Access Key" ||
      rule.name === "Generic Secret" ||
      rule.name === "JSON Secret" ||
      rule.name === ".env Secret"
    ) {
      counts.api += matchCount;
    } else {
      counts.other += matchCount;
    }
  }

  counts.other += countedEntropy;

  UpdateMaskedNumber(counts);
  return { maskedText: result, htmlMasked: htmlResult, counts };
}

function UpdateMaskedNumber(counts) {

  // 検知数合計
  console.log("Counts:", counts);
  const total = counts.email + counts.api + counts.custom + counts.other;

  // 各stat-cardの値を更新
  const statCards = document.querySelectorAll('.stat-card .value');
  if (statCards.length >= 4) {
    statCards[0].textContent = total;         // 検知数
    statCards[1].textContent = counts.email;  // メール
    statCards[2].textContent = counts.api;    // APIキー
    statCards[3].textContent = counts.custom; // カスタム
  }

    const detectioSuccess = document.querySelector('.detection.success');
    detectioSuccess.textContent=`${total}件をマスク済み / ${total} items masked`;

    const riskScore = document.querySelector('.risk-score');
    riskScore.classList.remove('low', 'medium', 'high');

    if (total === 0) {
      riskScore.textContent = "LOW";
      riskScore.classList.add('low');
    } else if (total < 5) {
      riskScore.textContent = "MEDIUM";
      riskScore.classList.add('medium');
    } else {
      riskScore.textContent = "HIGH";
      riskScore.classList.add('high');
    }



}


document
  .getElementById("maskButton")
  .addEventListener("click", () => {
    const original = inputText.value;
    const { maskedText, htmlMasked, counts } = maskText(original);
    // テキストはクリップボード用に保持、divにはHTMLで表示
    outputText.textContent = maskedText;
    outputText.innerHTML = htmlMasked;
    // コピー用に値を保持（グローバル変数で）
    window._lastMaskedText = maskedText;
  });


document
  .getElementById("copyButton")
  .addEventListener("click", async () => {
    try {
      // div表示なので、テキストのみコピー
      await navigator.clipboard.writeText(window._lastMaskedText || "");
      status.textContent = "コピーしました";
    } catch (err) {
      console.error(err);
      status.textContent = "コピー失敗";
    }
  });

document
  .getElementById("clearButton")
  .addEventListener("click", () => {
    inputText.value = "";
    outputText.value = "";
    status.textContent = "";
  });


// 起動時ロード
loadKeywords();

function exportOutput() {
  const text = outputText.value;
  if (!text) return;
  const blob = new Blob([text], { type: "text/plain" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "masked_output.txt";
  a.click();
  URL.revokeObjectURL(url);
}

function moveToDetectionRule() {
    // 検知ルールページへの遷移処理をここに追加
    window.location.href = "../DetectionRules/index.html";
}

function moveToCustomDictionary() {
    // カスタム辞書ページへの遷移処理をここに追加
    window.location.href = "../CustomDictionary/index.html";
}

function moveToDashboard() {
    // ダッシュボードページへの遷移処理をここに追加
    window.location.href = "../Dashboard/index.html";
}
