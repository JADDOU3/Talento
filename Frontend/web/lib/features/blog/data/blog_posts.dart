// lib/features/blog/data/blog_posts.dart

import 'package:flutter/material.dart';
import '../models/blog_post.dart';

const List<BlogPost> blogPosts = [
  BlogPost(
    id: 'our-story',
    icon: Icons.auto_awesome_rounded,
    titleEn: 'Our Story: Why We Built Talento',
    titleAr: 'قصتنا: لماذا أسسنا تالينتو',
    excerptEn:
    "Talento didn't start as an academic exercise — it began as a direct "
        "response to a real gap in how young children's talents are discovered.",
    excerptAr:
    'لم تنطلق تالينتو كفكرة نظرية، بل كاستجابة مباشرة لفجوة حقيقية في '
        'اكتشاف مواهب الأطفال في مراحلهم المبكرة.',
    bodyEn: [
      "Talento began as a direct response to a real gap in how children's "
          "talents and abilities are discovered during their early years. In "
          "many cases, parents still rely on unstructured observation or "
          "fragmented tools rather than a systematic approach.",
      "Over time, the project evolved into its current form: a model that "
          "combines an interactive kit with a digital platform, working as a "
          "single system. The goal is to turn play into a practical gateway "
          "for understanding a child's interests and abilities between the "
          "ages of 4 and 7, based on real interaction that is interpreted and "
          "analyzed systematically with the support of AI techniques.",
      "Talento was created to offer an interactive learning experience that "
          "doesn't rely on rote instruction or guesswork, but on a gradual "
          "understanding of a child's tendencies through interaction and "
          "behavioral data — giving parents a clearer picture of their "
          "children's strengths and developmental directions.",
      "We believe every child carries a unique talent waiting to be "
          "discovered. We design innovative learning experiences built on "
          "play and experimentation, through an integrated system of a kit "
          "and an AI-powered application, to help children discover their "
          "abilities and interests in areas such as creativity, thinking, "
          "and technology — while empowering parents to understand and "
          "support those tendencies.",
    ],
    bodyAr: [
      'انطلقت تالينتو استجابةً مباشرة لفجوة حقيقية في آليات اكتشاف وتنمية '
          'قدرات الأطفال في مراحلهم العمرية المبكرة، حيث ما زال الاعتماد في '
          'كثير من الحالات قائمًا على الملاحظة غير الممنهجة أو أدوات غير '
          'متكاملة.',
      'تطور المشروع تدريجيًا ليأخذ شكله الحالي كنموذج يجمع بين صندوق تفاعلي '
          'ومنصة رقمية تعملان ضمن منظومة واحدة، بهدف تحويل تجربة اللعب إلى '
          'مدخل عملي لفهم ميول الطفل وقدراته في الفئة العمرية من 4 إلى 7 '
          'سنوات، اعتمادًا على تفاعل فعلي يتم تفسيره وتحليله بشكل منهجي '
          'مدعوم بتقنيات الذكاء الاصطناعي.',
      'جاءت تالينتو لتقدّم تجربة تعليمية تفاعلية لا تعتمد على التلقين أو '
          'التخمين، بل على بناء فهم تدريجي لميول الطفل عبر التفاعل والبيانات '
          'السلوكية، بما يتيح للأهل قراءة أوضح لنقاط القوة والاتجاهات '
          'التطورية لدى أطفالهم.',
      'نؤمن أن داخل كل طفل موهبة فريدة تنتظر من يكتشفها. نصمم تجارب تعليمية '
          'مبتكرة قائمة على اللعب والتجربة، عبر نظام متكامل من صندوق وتطبيق '
          'مدعوم بالذكاء الاصطناعي، لمساعدة الأطفال على اكتشاف قدراتهم '
          'واهتماماتهم في مجالات مثل الإبداع والتفكير والتكنولوجيا، وتمكين '
          'الأهل من فهم ميول أطفالهم ودعمها.',
    ],
  ),
  BlogPost(
    id: 'the-problem',
    icon: Icons.query_stats_rounded,
    titleEn: 'The Problem We\'re Solving',
    titleAr: 'المشكلة التي نسعى لحلها',
    excerptEn:
    'A field survey of 430 Palestinian families revealed a clear gap '
        "between parents' interest in discovering their children's talents "
        'and the tools available to help them.',
    excerptAr:
    'أظهر استطلاع ميداني شمل 430 أسرة فلسطينية فجوة واضحة بين اهتمام '
        'الأهل باكتشاف مواهب أطفالهم ومحدودية الأدوات المتاحة لمساعدتهم.',
    bodyEn: [
      "Many parents face real challenges discovering their children's "
          'talents and abilities during the early years of life, largely '
          'because the practical solutions available are so limited. Much '
          'of the current approach still relies on personal judgment or '
          'unstructured observation rather than a systematic method.',
      'To measure the scale of this gap, we conducted a field survey '
          'covering 430 Palestinian families. The results showed that 89.6% '
          "of parents are genuinely interested in discovering their "
          "children's talents and abilities, while 77.2% said they don't "
          'actively pursue this because current solutions are too weak to '
          'help them. Separately, 33.3% of families said they begin paying '
          'attention to discovery specifically between ages 4–5 — the stage '
          "that marks the real starting point for a child's development.",
      'These results point to a high level of parental interest paired with '
          'a clear need for more effective, methodical solutions to help '
          "families discover and nurture their children's talents — and "
          'that is exactly the gap Talento was built to close.',
    ],
    bodyAr: [
      'يواجه العديد من أولياء الأمور تحديًا حقيقيًا في اكتشاف مواهب وقدرات '
          'أطفالهم خلال السنوات الأولى من العمر، نظرًا لمحدودية الحلول '
          'العملية المتاحة، إذ لا تزال الكثير من الأساليب الحالية تعتمد على '
          'الاجتهاد الشخصي أو الملاحظة غير المنظمة.',
      'وللتحقق من حجم هذه الفجوة، أجرينا استطلاعًا ميدانيًا شمل 430 أسرة '
          'فلسطينية، أظهر أن 89.6% من الأهل مهتمون فعليًا باكتشاف مواهب '
          'أطفالهم، في حين أفاد 77.2% منهم بأنهم لا يسعون لذلك بسبب ضعف '
          'الحلول الحالية. كما تبيّن أن 33.3% من الأسر تبدأ اهتمامها '
          'بالاكتشاف في الفئة العمرية 4–5 سنوات، وهي المرحلة التي تمثل نقطة '
          'الانطلاق الحقيقية لتطور قدرات الطفل.',
      'تعكس هذه النتائج وجود اهتمام مرتفع لدى الأهالي، يقابله احتياج واضح '
          'إلى حلول أكثر فاعلية ومنهجية تساعدهم على اكتشاف مواهب وقدرات '
          'أطفالهم وتنميتها — وهي الفجوة ذاتها التي انطلقت منها فكرة '
          'تالينتو.',
    ],
  ),
  BlogPost(
    id: 'how-it-works',
    icon: Icons.widgets_rounded,
    titleEn: 'How Talento Works',
    titleAr: 'كيف تعمل تالينتو',
    excerptEn:
    'An interactive kit and a digital platform work together as one '
        'system — turning everyday play into insight parents can actually '
        'use.',
    excerptAr:
    'صندوق تفاعلي ومنصة رقمية يعملان كوحدة واحدة، ليحوّلا تجربة اللعب '
        'اليومية إلى مؤشرات يفهمها الأهل ويستفيدون منها فعليًا.',
    bodyEn: [
      "Talento offers an integrated system designed to support the "
          "discovery of children's talents and abilities during their early "
          "years, by combining a hands-on interactive experience with a "
          "digital platform that work together as a single unit.",
      "The solution centers on an interactive kit designed for children "
          "between the ages of 4 and 7, through which play- and "
          "experience-based activities are carried out. In parallel, a "
          "digital platform records the child's interaction with these "
          "activities and analyzes it in a simplified way.",
      "Digital analysis techniques, supported by intelligent mechanisms "
          "within an initial framework, are used to interpret the child's "
          "interaction and behavior, with the goal of producing simplified "
          "performance reports that help parents better understand learning "
          "patterns and tendencies.",
      "This integration between the physical and digital sides, combined "
          "with intelligent data analysis, turns the daily play experience "
          "into understandable, trackable indicators — moving families away "
          "from relying on random observation.",
    ],
    bodyAr: [
      'تقدّم تالينتو نظامًا متكاملًا يهدف إلى دعم عملية اكتشاف مواهب وقدرات '
          'الأطفال في المراحل العمرية المبكرة، من خلال دمج تجربة عملية '
          'تفاعلية مع منصة رقمية تعملان كوحدة واحدة.',
      'يعتمد الحل على صندوق تفاعلي موجّه للأطفال ضمن الفئة العمرية من 4 إلى '
          '7 سنوات، يتم من خلاله تنفيذ أنشطة قائمة على اللعب والتجربة، '
          'بالتوازي مع منصة رقمية تسجّل تفاعل الطفل مع هذه الأنشطة وتحلّلها '
          'بشكل مبسّط.',
      'يتم توظيف تقنيات التحليل الرقمي المدعومة بآليات ذكية، ضمن إطار أولي، '
          'في تفسير تفاعل وسلوك الطفل، بهدف تقديم تقارير أداء مبسطة تساعد '
          'الأهل على فهم أنماط التعلم والميول بشكل أوضح.',
      'يتيح هذا التكامل بين الجانب الفيزيائي والرقمي، إلى جانب التحليل '
          'الذكي للبيانات، تحويل التجربة اليومية إلى مؤشرات قابلة للفهم '
          'والمتابعة، بعيدًا عن الاعتماد على الملاحظة العشوائية.',
    ],
  ),
  BlogPost(
    id: 'vision-and-values',
    icon: Icons.flag_rounded,
    titleEn: 'Our Vision and Values',
    titleAr: 'رؤيتنا وقيمنا',
    excerptEn:
    "Sparking every child's curiosity to discover their talent and "
        'shape their future — through a journey that begins with play and '
        'ends in excellence.',
    excerptAr:
    'إطلاق فضول كل طفل ليكتشف موهبته ويصنع مستقبله، في رحلة ممتعة تبدأ '
        'باللعب وتنتهي بالتميز.',
    bodyEn: [
      "Our mission: we believe every child holds a unique talent waiting to "
          "be discovered. We design innovative learning experiences built "
          "on play and experimentation, delivered through an integrated "
          "system of a kit and an AI-powered app, to help children discover "
          "their abilities and interests in areas like creativity, "
          "thinking, and technology — while helping parents understand and "
          "support those tendencies.",
      "Our vision: to spark every child's curiosity to discover their "
          "talent and build their future, through an enjoyable journey that "
          "begins with play and ends in excellence.",
      "Our values: transparency, continuous development and innovation, and "
          "honesty guide everything we build — from how we design "
          "activities to how we handle every family's data.",
      "We approach this work with a strong sense of responsibility toward "
          "children's safety and privacy, and toward giving parents a fair, "
          "unbiased experience that combines learning through play with "
          "genuine discovery.",
    ],
    bodyAr: [
      'رسالتنا: نؤمن أن داخل كل طفل موهبة فريدة تنتظر من يكتشفها. نصمم '
          'تجارب تعليمية مبتكرة قائمة على اللعب والتجربة، عبر نظام متكامل من '
          'صندوق وتطبيق مدعوم بالذكاء الاصطناعي، لمساعدة الأطفال على اكتشاف '
          'قدراتهم واهتماماتهم في مجالات مثل الإبداع والتفكير والتكنولوجيا، '
          'وتمكين الأهل من فهم ميول أطفالهم ودعمها.',
      'رؤيتنا: إطلاق فضول كل طفل ليكتشف موهبته ويصنع مستقبله في رحلة ممتعة '
          'تبدأ باللعب وتنتهي بالتميز.',
      'قيمنا: الشفافية، والتطوير والابتكار المستمر، والصدق في كل ما نقدمه — '
          'من تصميم الأنشطة إلى طريقة تعاملنا مع بيانات كل أسرة.',
      'ننطلق في عملنا من إحساس عالٍ بالمسؤولية تجاه سلامة الأطفال وخصوصيتهم، '
          'وتجاه تقديم تجربة عادلة وغير متحيزة للأهل تجمع بين التعلم باللعب '
          'والاكتشاف الحقيقي.',
    ],
  ),
];