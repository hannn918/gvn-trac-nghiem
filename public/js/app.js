const SUPABASE_URL = "https://vjxuyghzhgchdtncsrjn.supabase.co";
const SUPABASE_KEY = "sb_publishable_6BJF9F_QQK5JOrEjw1dDHA_sCCc-tDm";

let currentQuestions = [];
let candidateData = null;
let candidateId = null;
let latestResultId = null;

const infoSection = document.getElementById("infoSection");
const quizSection = document.getElementById("quizSection");
const resultSection = document.getElementById("resultSection");
const detailSection = document.getElementById("detailSection");

const candidateForm = document.getElementById("candidateForm");
const questionList = document.getElementById("questionList");
const submitBtn = document.getElementById("submitBtn");
const answerCount = document.getElementById("answerCount");

candidateForm.addEventListener("submit", async (event) => {
  event.preventDefault();

  candidateData = {
    ho_ten: document.getElementById("hoTen").value.trim(),
    so_dien_thoai: document.getElementById("soDienThoai").value.trim(),
  };

  if (!candidateData.ho_ten || !candidateData.so_dien_thoai) {
    alert("Vui lòng nhập họ tên và số điện thoại.");
    return;
  }

  await startQuiz();
});

submitBtn.addEventListener("click", submitQuiz);

async function supabaseRequest(path, options = {}) {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...options,
    headers: {
      apikey: SUPABASE_KEY,
      Authorization: `Bearer ${SUPABASE_KEY}`,
      "Content-Type": "application/json",
      Prefer: "return=representation",
      ...(options.headers || {}),
    },
  });

  const text = await response.text();
  const data = text ? JSON.parse(text) : null;

  if (!response.ok) {
    console.error("Supabase error:", data);
    throw new Error(data?.message || "Có lỗi khi kết nối Supabase.");
  }

  return data;
}

async function startQuiz() {
  try {
    const startBtn = candidateForm.querySelector("button");
    startBtn.disabled = true;
    startBtn.innerText = "Đang tải câu hỏi...";

    const insertedCandidate = await supabaseRequest("ung_vien", {
      method: "POST",
      body: JSON.stringify(candidateData),
    });

    candidateId = insertedCandidate[0].id;

    const allQuestions = await supabaseRequest(
      "cau_hoi?select=id,noi_dung,dap_an_a,dap_an_b,dap_an_c,dap_an_d,dap_an_dung&trang_thai=eq.true"
    );

    currentQuestions = shuffleArray(allQuestions).slice(0, 10);

    if (currentQuestions.length < 10) {
      alert("Database chưa đủ 10 câu hỏi.");
      return;
    }

    renderQuestions();

    infoSection.classList.add("hidden");
    resultSection.classList.add("hidden");
    detailSection.classList.add("hidden");
    quizSection.classList.remove("hidden");
  } catch (error) {
    alert(error.message);
  } finally {
    const startBtn = candidateForm.querySelector("button");
    startBtn.disabled = false;
    startBtn.innerText = "Bắt đầu làm bài";
  }
}

function renderQuestions() {
  questionList.innerHTML = "";

  currentQuestions.forEach((question, index) => {
    const questionCard = document.createElement("div");
    questionCard.className = "question-card";

    questionCard.innerHTML = `
      <div class="question-title">
        <span class="question-number">${index + 1}</span>
        <span>${question.noi_dung}</span>
      </div>

      <div class="answers">
        ${renderAnswer(question.id, "A", question.dap_an_a)}
        ${renderAnswer(question.id, "B", question.dap_an_b)}
        ${renderAnswer(question.id, "C", question.dap_an_c)}
        ${renderAnswer(question.id, "D", question.dap_an_d)}
      </div>
    `;

    questionList.appendChild(questionCard);
  });

  if (answerCount) {
    answerCount.innerText = "0/10 đã chọn";
  }

  document.querySelectorAll(".answer-input").forEach((input) => {
    input.addEventListener("change", updateAnswerCount);
  });
}

function renderAnswer(questionId, option, content) {
  return `
    <label class="answer-item">
      <input 
        class="answer-input" 
        type="radio" 
        name="question_${questionId}" 
        value="${option}"
      />
      <span class="answer-label">
        <strong>${option}.</strong> ${content}
      </span>
    </label>
  `;
}

function updateAnswerCount() {
  const selectedCount = getSelectedAnswers().length;

  if (answerCount) {
    answerCount.innerText = `${selectedCount}/10 đã chọn`;
  }
}

function getSelectedAnswers() {
  return currentQuestions
    .map((question) => {
      const selected = document.querySelector(
        `input[name="question_${question.id}"]:checked`
      );

      if (!selected) return null;

      return {
        id_cau_hoi: question.id,
        dap_an_chon: selected.value,
        dap_an_dung: question.dap_an_dung,
        la_dung: selected.value === question.dap_an_dung,
        question,
      };
    })
    .filter(Boolean);
}

async function submitQuiz() {
  const selectedAnswers = getSelectedAnswers();

  if (selectedAnswers.length < 10) {
    alert("Vui lòng chọn đủ 10 câu trước khi xác nhận.");
    return;
  }

  try {
    submitBtn.disabled = true;
    submitBtn.innerText = "Đang chấm điểm...";

    const correctCount = selectedAnswers.filter((item) => item.la_dung).length;
    const wrongCount = 10 - correctCount;
    const resultStatus = correctCount >= 8 ? "dau" : "rot";

    const insertedResult = await supabaseRequest("bai_lam", {
      method: "POST",
      body: JSON.stringify({
        id_ung_vien: candidateId,
        tong_cau: 10,
        so_cau_dung: correctCount,
        so_cau_sai: wrongCount,
        ket_qua: resultStatus,
        thoi_gian_nop: new Date().toISOString(),
      }),
    });

    latestResultId = insertedResult[0].id;

    const detailRows = selectedAnswers.map((item) => ({
      id_bai_lam: latestResultId,
      id_cau_hoi: item.id_cau_hoi,
      dap_an_chon: item.dap_an_chon,
      dap_an_dung: item.dap_an_dung,
      la_dung: item.la_dung,
    }));

    await supabaseRequest("chi_tiet_bai_lam", {
      method: "POST",
      body: JSON.stringify(detailRows),
    });

    renderResult(correctCount, wrongCount, resultStatus);

    quizSection.classList.add("hidden");
    resultSection.classList.remove("hidden");
    window.scrollTo({ top: 0, behavior: "smooth" });
  } catch (error) {
    alert(error.message);
  } finally {
    submitBtn.disabled = false;
    submitBtn.innerText = "Xác nhận kết quả";
  }
}

function renderResult(correctCount, wrongCount, resultStatus) {
  const isPass = resultStatus === "dau";

  resultSection.innerHTML = `
    <div class="card result-card">
      <div class="result-icon ${isPass ? "result-pass" : "result-fail"}">
        ${isPass ? "✓" : "×"}
      </div>

      <h2 class="result-title ${isPass ? "pass" : "fail"}">
        ${isPass ? "ĐẬU" : "RỚT"}
      </h2>

      <p class="result-message">
        ${
          isPass
            ? "Chúc mừng, ứng viên đạt yêu cầu bài test."
            : "Ứng viên chưa đạt yêu cầu. Có thể làm lại bài test."
        }
      </p>

      <div class="result-stats">
        <div class="stat-item">
          <span class="stat-number">${correctCount}/10</span>
          <span class="stat-label">Câu đúng</span>
        </div>

        <div class="stat-item">
          <span class="stat-number">${wrongCount}</span>
          <span class="stat-label">Câu sai</span>
        </div>

        <div class="stat-item">
          <span class="stat-number">${correctCount}</span>
          <span class="stat-label">Điểm</span>
        </div>
      </div>

      <div class="result-actions">
        <button class="btn btn-secondary" type="button" onclick="showDetail()">
          Xem chi tiết
        </button>

        <button class="btn btn-primary" type="button" onclick="location.reload()">
          Làm bài lần nữa
        </button>
      </div>
    </div>
  `;
}

function showDetail() {
  const selectedAnswers = getSelectedAnswers();

  let html = `
    <div class="card">
      <h2 class="card-title">Chi tiết đúng / sai</h2>
      <p class="card-desc">Danh sách câu trả lời của ứng viên.</p>
  `;

  selectedAnswers.forEach((item, index) => {
    html += `
      <div class="question-card">
        <div class="question-title">
          <span class="question-number">${index + 1}</span>
          <span>${item.question.noi_dung}</span>
        </div>

        <p>
          <strong>Đáp án đã chọn:</strong>
          ${formatAnswer(item.question, item.dap_an_chon)}
        </p>

        <p>
          <strong>Đáp án đúng:</strong>
          ${formatAnswer(item.question, item.dap_an_dung)}
        </p>

        <p>
          <strong>Kết quả:</strong>
          <span style="color:${item.la_dung ? "#16803f" : "#d63939"}; font-weight:700;">
            ${item.la_dung ? "Đúng" : "Sai"}
          </span>
        </p>
      </div>
    `;
  });

  html += `</div>`;

  detailSection.innerHTML = html;
  detailSection.classList.remove("hidden");
  detailSection.scrollIntoView({ behavior: "smooth" });
}

function formatAnswer(question, answerKey) {
  if (!answerKey) return "Chưa chọn";

  const key = `dap_an_${answerKey.toLowerCase()}`;
  const content = question[key] || "";

  return `<span class="answer-full-text">${answerKey}: ${content}</span>`;
}

function shuffleArray(array) {
  const copiedArray = [...array];

  for (let i = copiedArray.length - 1; i > 0; i--) {
    const randomIndex = Math.floor(Math.random() * (i + 1));

    [copiedArray[i], copiedArray[randomIndex]] = [
      copiedArray[randomIndex],
      copiedArray[i],
    ];
  }

  return copiedArray;
}