class TarotCard {
  final String name;
  final String nameJp;
  final String emoji;
  final String meaning;
  final String reversedMeaning;
  final String keywords;

  const TarotCard({
    required this.name,
    required this.nameJp,
    required this.emoji,
    required this.meaning,
    required this.reversedMeaning,
    required this.keywords,
  });
}

const List<TarotCard> majorArcana = [
  TarotCard(name: 'The Fool', nameJp: '愚者', emoji: '🌟', meaning: '新しい始まり、純粋な可能性、自由な魂', reversedMeaning: '無謀、無計画、衝動的な行動', keywords: '出発・冒険・無限の可能性'),
  TarotCard(name: 'The Magician', nameJp: '魔術師', emoji: '🪄', meaning: '意志力、創造力、技術・才能の活用', reversedMeaning: '操作、詐欺、才能の無駄遣い', keywords: '実現・行動・集中力'),
  TarotCard(name: 'The High Priestess', nameJp: '女教皇', emoji: '🌙', meaning: '直感、内なる知恵、神秘的な理解', reversedMeaning: '秘密の暴露、感情的な混乱', keywords: '直感・神秘・内省'),
  TarotCard(name: 'The Empress', nameJp: '女帝', emoji: '🌹', meaning: '豊かさ、創造性、母性、自然との調和', reversedMeaning: '依存、創造力の欠如、停滞', keywords: '豊穣・育成・感受性'),
  TarotCard(name: 'The Emperor', nameJp: '皇帝', emoji: '👑', meaning: '権威、安定、構造、指導力', reversedMeaning: '権威主義、柔軟性のなさ、支配欲', keywords: '秩序・安定・リーダーシップ'),
  TarotCard(name: 'The Hierophant', nameJp: '法王', emoji: '⛪', meaning: '伝統、精神的な教え、慣習への従順', reversedMeaning: '慣習への反抗、個人の信念の探求', keywords: '信仰・教育・伝統'),
  TarotCard(name: 'The Lovers', nameJp: '恋人', emoji: '💕', meaning: '愛、調和、重要な選択、深いつながり', reversedMeaning: '不調和、誘惑、誤った選択', keywords: '愛情・選択・統合'),
  TarotCard(name: 'The Chariot', nameJp: '戦車', emoji: '⚡', meaning: '勝利、決断力、意志の強さ、克服', reversedMeaning: '方向性の欠如、自己コントロールの喪失', keywords: '前進・勝利・自制心'),
  TarotCard(name: 'Strength', nameJp: '力', emoji: '🦁', meaning: '内なる力、勇気、忍耐、優しさ', reversedMeaning: '自己疑念、弱さ、感情の爆発', keywords: '勇気・忍耐・内なる強さ'),
  TarotCard(name: 'The Hermit', nameJp: '隠者', emoji: '🏔️', meaning: '内省、孤独、精神的な探求、知恵', reversedMeaning: '孤立、内省の拒否、孤独感', keywords: '内省・知恵・精神的探求'),
  TarotCard(name: 'Wheel of Fortune', nameJp: '運命の輪', emoji: '🎡', meaning: '運命の変化、幸運の転換点、サイクル', reversedMeaning: '不運、変化への抵抗、悪循環', keywords: '転機・運命・循環'),
  TarotCard(name: 'Justice', nameJp: '正義', emoji: '⚖️', meaning: '公平、真実、因果応報、バランス', reversedMeaning: '不公平、偏見、回避', keywords: '公正・バランス・真実'),
  TarotCard(name: 'The Hanged Man', nameJp: '吊された男', emoji: '🔮', meaning: '一時停止、新しい視点、犠牲', reversedMeaning: '遅延、抵抗、無駄な犠牲', keywords: '視点の転換・受容・待機'),
  TarotCard(name: 'Death', nameJp: '死神', emoji: '🌑', meaning: '変容、終わりと始まり、根本的な変化', reversedMeaning: '変化への抵抗、停滞、過去への執着', keywords: '変容・終焉・再生'),
  TarotCard(name: 'Temperance', nameJp: '節制', emoji: '🌊', meaning: 'バランス、調和、忍耐、中庸', reversedMeaning: '不均衡、過剰、焦り', keywords: '調和・バランス・統合'),
  TarotCard(name: 'The Devil', nameJp: '悪魔', emoji: '🔗', meaning: '束縛、物質主義、誘惑、影の自己', reversedMeaning: '解放、束縛からの脱出、啓示', keywords: '執着・誘惑・束縛'),
  TarotCard(name: 'The Tower', nameJp: '塔', emoji: '⚡', meaning: '突然の変化、崩壊、真実の啓示', reversedMeaning: '変化の回避、小さな混乱', keywords: '崩壊・啓示・解放'),
  TarotCard(name: 'The Star', nameJp: '星', emoji: '⭐', meaning: '希望、インスピレーション、精神的な平和', reversedMeaning: '絶望、方向性の喪失、悲観', keywords: '希望・癒し・インスピレーション'),
  TarotCard(name: 'The Moon', nameJp: '月', emoji: '🌕', meaning: '幻想、直感、夢、潜在意識', reversedMeaning: '混乱の解消、真実の暴露、明晰さ', keywords: '直感・幻想・潜在意識'),
  TarotCard(name: 'The Sun', nameJp: '太陽', emoji: '☀️', meaning: '喜び、成功、活力、明るい未来', reversedMeaning: '過剰な楽観、一時的な曇り', keywords: '成功・喜び・活力'),
  TarotCard(name: 'Judgement', nameJp: '審判', emoji: '🎺', meaning: '覚醒、再生、過去の清算、新たな始まり', reversedMeaning: '自己疑念、過去への囚われ', keywords: '覚醒・刷新・使命'),
  TarotCard(name: 'The World', nameJp: '世界', emoji: '🌍', meaning: '完成、統合、達成、新しいサイクルの始まり', reversedMeaning: '未完成、停滞、制限感', keywords: '完成・統合・達成'),
];

String getZodiacSign(DateTime birthdate) {
  final month = birthdate.month;
  final day = birthdate.day;
  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '♈ おひつじ座';
  if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '♉ おうし座';
  if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return '♊ ふたご座';
  if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return '♋ かに座';
  if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '♌ しし座';
  if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '♍ おとめ座';
  if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) return '♎ てんびん座';
  if ((month == 10 && day >= 24) || (month == 11 && day <= 22)) return '♏ さそり座';
  if ((month == 11 && day >= 23) || (month == 12 && day <= 21)) return '♐ いて座';
  if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '♑ やぎ座';
  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '♒ みずがめ座';
  return '♓ うお座';
}
