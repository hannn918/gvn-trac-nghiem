const express = require('express');
const router = express.Router();
const quizController = require('../controllers/quiz.controller');

router.post('/bai-lam/bat-dau', quizController.startQuiz);
router.post('/bai-lam/nop-bai', quizController.submitQuiz);
router.get('/bai-lam/:id', quizController.getResult);
router.get('/lich-su/:so_dien_thoai', quizController.getHistoryByPhone);

module.exports = router;
