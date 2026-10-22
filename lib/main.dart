
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartCRMApp());
}

const Color primaryColor = Color(0xFF087F5B);
const Color backgroundColor = Color(0xFFF5F7F8);

class KnowledgeItem {
  String question;
  String answer;

  KnowledgeItem(this.question, this.answer);
}

class ChatRecord {
  final String question;
  final String answer;
  final DateTime time;

  ChatRecord(this.question, this.answer) : time = DateTime.now();
}

class SmartCRMApp extends StatelessWidget {
  const SmartCRMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartCRM AI',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF172B26),
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE1E8E5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE1E8E5)),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: CRMHome(),
      ),
    );
  }
}

class CRMHome extends StatefulWidget {
  const CRMHome({super.key});

  @override
  State<CRMHome> createState() => _CRMHomeState();
}

class _CRMHomeState extends State<CRMHome> {
  int selectedIndex = 0;

  String companyName = 'شركتي';
  String botName = 'المساعد الذكي';
  String welcomeMessage = 'مرحباً بك! كيف يمكنني مساعدتك؟';
  String fallbackMessage =
      'عذراً، لا أملك إجابة مؤكدة عن هذا السؤال. يرجى التواصل مع الشركة.';
  String replyStyle = 'احترافي';
  bool botEnabled = true;

  final List<KnowledgeItem> knowledge = [
    KnowledgeItem(
      'ما هي خدماتكم؟',
      'نقدم خدماتنا وفق احتياجات العملاء. تواصل معنا لمعرفة التفاصيل.',
    ),
    KnowledgeItem(
      'ما أوقات العمل؟',
      'أوقات العمل من الأحد إلى الخميس، من الساعة 8 صباحاً حتى 5 مساءً.',
    ),
    KnowledgeItem(
      'كيف أتواصل معكم؟',
      'يمكنك التواصل مع فريق خدمة العملاء عبر قنوات التواصل المعتمدة.',
    ),
  ];

  final List<ChatRecord> chatHistory = [];

  final List<String> pageTitles = [
    'لوحة التحكم',
    'قاعدة المعرفة',
    'تجربة الشات بوت',
    'سجل المحادثات',
    'إعدادات البوت',
    'قنوات التواصل',
    'إعدادات الشركة',
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void openKnowledgeDialog({KnowledgeItem? item}) {
    final questionController = TextEditingController(
      text: item?.question ?? '',
    );
    final answerController = TextEditingController(
      text: item?.answer ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item == null ? 'إضافة سؤال جديد' : 'تعديل السؤال'),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'سؤال العميل',
                    hintText: 'مثال: ما أوقات العمل؟',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: answerController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'إجابة البوت',
                    hintText: 'اكتب الإجابة المعتمدة هنا',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final question = questionController.text.trim();
              final answer = answerController.text.trim();

              if (question.isEmpty || answer.isEmpty) {
                showMessage('يرجى إدخال السؤال والإجابة');
                return;
              }

              setState(() {
                if (item == null) {
                  knowledge.add(KnowledgeItem(question, answer));
                } else {
                  item.question = question;
                  item.answer = answer;
                }
              });

              Navigator.pop(dialogContext);
              showMessage('تم حفظ البيانات في الذاكرة الحالية');
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  String getBotAnswer(String question) {
    if (!botEnabled) {
      return 'المساعد غير متاح حالياً. يرجى التواصل مع الشركة.';
    }

    final normalizedQuestion = question.toLowerCase().trim();

    KnowledgeItem? bestMatch;

    for (final item in knowledge) {
      final normalizedStored = item.question.toLowerCase().trim();

      if (normalizedQuestion == normalizedStored ||
          normalizedQuestion.contains(normalizedStored) ||
          normalizedStored.contains(normalizedQuestion)) {
        bestMatch = item;
        break;
      }
    }

    if (bestMatch != null) {
      return bestMatch.answer;
    }

    for (final item in knowledge) {
      final words = item.question
          .toLowerCase()
          .replaceAll('؟', '')
          .replaceAll('?', '')
          .split(RegExp(r'\s+'));

      for (final word in words) {
        if (word.length > 3 && normalizedQuestion.contains(word)) {
          return item.answer;
        }
      }
    }

    return fallbackMessage;
  }

  Widget buildPage() {
    switch (selectedIndex) {
      case 0:
        return buildDashboard();
      case 1:
        return buildKnowledgePage();
      case 2:
        return ChatPage(
          botName: botName,
          welcomeMessage: welcomeMessage,
          getAnswer: getBotAnswer,
          onMessage: (question, answer) {
            setState(() {
              chatHistory.insert(0, ChatRecord(question, answer));
            });
          },
        );
      case 3:
        return buildHistoryPage();
      case 4:
        return buildBotSettingsPage();
      case 5:
        return buildChannelsPage();
      case 6:
        return buildCompanyPage();
      default:
        return buildDashboard();
    }
  }

  Widget buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'مرحباً بك في $companyName',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'إدارة مساعدك الذكي للرد على استفسارات العملاء.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 700 ? 4 : 2;
            final cardWidth =
                (constraints.maxWidth - (columns - 1) * 12) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'الأسئلة المعرفة',
                    value: '${knowledge.length}',
                    icon: Icons.menu_book_outlined,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'المحادثات',
                    value: '${chatHistory.length}',
                    icon: Icons.chat_bubble_outline,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'حالة البوت',
                    value: botEnabled ? 'نشط' : 'متوقف',
                    icon: Icons.smart_toy_outlined,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'قنوات الربط',
                    value: 'واجهة تجريبية',
                    icon: Icons.hub_outlined,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'الوصول السريع',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        QuickAction(
          title: 'إدارة قاعدة المعرفة',
          subtitle: 'أضف الأسئلة والإجابات التي يعتمد عليها البوت.',
          icon: Icons.library_books_outlined,
          onTap: () => setState(() => selectedIndex = 1),
        ),
        QuickAction(
          title: 'اختبار المحادثة',
          subtitle: 'جرّب إرسال أسئلة إلى المساعد.',
          icon: Icons.chat_outlined,
          onTap: () => setState(() => selectedIndex = 2),
        ),
        QuickAction(
          title: 'تخصيص البوت',
          subtitle: 'عدّل الاسم ورسالة الترحيب والإعدادات.',
          icon: Icons.tune,
          onTap: () => setState(() => selectedIndex = 4),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'تنبيه: هذه نسخة تجريبية تحفظ البيانات في ذاكرة التطبيق فقط. '
              'البيانات قد تختفي عند إعادة تشغيله. لا يوجد اتصال فعلي بخدمة '
              'ذكاء اصطناعي أو واتساب في هذه النسخة.',
            ),
          ),
        ),
      ],
    );
  }

  Widget buildKnowledgePage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'الأسئلة والأجوبة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: () => openKnowledgeDialog(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة'),
              ),
            ],
          ),
        ),
        Expanded(
          child: knowledge.isEmpty
              ? const Center(child: Text('لا توجد أسئلة. أضف سؤالاً جديداً.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: knowledge.length,
                  itemBuilder: (context, index) {
                    final item = knowledge[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.question,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(item.answer),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: 'تعديل',
                                  onPressed: () =>
                                      openKnowledgeDialog(item: item),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'حذف',
                                  onPressed: () {
                                    setState(() => knowledge.remove(item));
                                    showMessage('تم حذف السؤال');
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildHistoryPage() {
    if (chatHistory.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'لا توجد محادثات حتى الآن.\n'
            'افتح صفحة تجربة الشات بوت وابدأ محادثة.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chatHistory.length,
      itemBuilder: (context, index) {
        final record = chatHistory[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سؤال العميل: ${record.question}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('رد البوت: ${record.answer}'),
                const SizedBox(height: 8),
                Text(
                  '${record.time.hour.toString().padLeft(2, '0')}:'
                  '${record.time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildBotSettingsPage() {
    return SettingsForm(
      botName: botName,
      welcomeMessage: welcomeMessage,
      fallbackMessage: fallbackMessage,
      replyStyle: replyStyle,
      botEnabled: botEnabled,
      onSave: (name, welcome, fallback, style, enabled) {
        setState(() {
          botName = name;
          welcomeMessage = welcome;
          fallbackMessage = fallback;
          replyStyle = style;
          botEnabled = enabled;
        });
        showMessage('تم تحديث إعدادات البوت في الذاكرة الحالية');
      },
    );
  }

  Widget buildChannelsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'قنوات التواصل',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('اختر القناة التي تريد تجهيزها لعملائك.'),
        const SizedBox(height: 16),
        const ChannelCard(
          title: 'المحادثة داخل البرنامج',
          description: 'واجهة تجريبية لاختبار ردود المساعد.',
          icon: Icons.chat_bubble_outline,
          status: 'متاحة للتجربة',
        ),
        const ChannelCard(
          title: 'WhatsApp Business',
          description:
              'يتطلب الربط الفعلي إعداد WhatsApp Business Platform '
              'وخادماً خلفياً وبيانات اعتماد رسمية.',
          icon: Icons.phone_android,
          status: 'غير متصل',
        ),
        const ChannelCard(
          title: 'موقع الشركة',
          description:
              'يمكن لاحقاً تضمين نافذة المحادثة في موقع الشركة '
              'من خلال واجهة برمجية.',
          icon: Icons.language,
          status: 'غير متصل',
        ),
      ],
    );
  }

  Widget buildCompanyPage() {
    final controller = TextEditingController(text: companyName);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'إعدادات الشركة',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم الشركة',
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            final value = controller.text.trim();

            if (value.isEmpty) {
              showMessage('يرجى كتابة اسم الشركة');
              return;
            }

            setState(() => companyName = value);
            showMessage('تم تحديث اسم الشركة');
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('حفظ بيانات الشركة'),
        ),
        const SizedBox(height: 16),
        const Text(
          'هذه البيانات تجريبية ولا يتم حفظها بعد إغلاق التطبيق. '
          'يلزم ربط قاعدة بيانات لتخزينها بشكل دائم.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: primaryColor),
            const SizedBox(width: 10),
            Text(
              'SmartCRM AI',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: primaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.white,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SmartCRM AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      companyName,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: pageTitles.length,
                  itemBuilder: (context, index) {
                    final icons = [
                      Icons.dashboard_outlined,
                      Icons.menu_book_outlined,
                      Icons.chat_outlined,
                      Icons.history,
                      Icons.tune,
                      Icons.hub_outlined,
                      Icons.business_outlined,
                    ];

                    return ListTile(
                      selected: selectedIndex == index,
                      leading: Icon(icons[index]),
                      title: Text(pageTitles[index]),
                      onTap: () {
                        setState(() => selectedIndex = index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'الإصدار التجريبي 1.0',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
      body: buildPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex > 3 ? 0 : selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'المعرفة',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            label: 'المحادثة',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'السجل',
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String botName;
  final String welcomeMessage;
  final String Function(String) getAnswer;
  final void Function(String, String) onMessage;

  const ChatPage({
    super.key,
    required this.botName,
    required this.welcomeMessage,
    required this.getAnswer,
    required this.onMessage,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    messages.add({
      'role': 'bot',
      'text': widget.welcomeMessage,
    });
  }

  void sendMessage() {
    final question = controller.text.trim();

    if (question.isEmpty) return;

    final answer = widget.getAnswer(question);

    setState(() {
      messages.add({'role': 'user', 'text': question});
      messages.add({'role': 'bot', 'text': answer});
    });

    widget.onMessage(question, answer);
    controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @@override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    messages.add({
      'role': 'bot',
      'text': widget.welcomeMessage,
    });
  }

  void sendMessage() {
    final question = controller.text.trim();

    if (question.isEmpty) return;

    final answer = widget.getAnswer(question);

    setState(() {
      messages.add({'role': 'user', 'text': question});
      messages.add({'role': 'bot', 'text': answer});
    });

    widget.onMessage(question, answer);
    controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

 @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE0F3EB),
                child: Icon(Icons.smart_toy_outlined, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.botName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'وضع التجربة المحلي',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isUser = message['role'] == 'user';

              return Align(
                alignment:
                    isUser ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message['text'] ?? '',
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'اكتب سؤال العميل...',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsForm extends StatefulWidget {
  final String botName;
  final String welcomeMessage;
  final String fallbackMessage;
  final String replyStyle;
  final bool botEnabled;

  final void Function(
    String,
    String,
    String,
    String,
    bool,
  ) onSave;

  const SettingsForm({
    super.key,
    required this.botName,
    required this.welcomeMessage,
    required this.fallbackMessage,
    required this.replyStyle,
    required this.botEnabled,
    required this.onSave,
  });

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  late final TextEditingController nameController;
  late final TextEditingController welcomeController;
  late final TextEditingController fallbackController;

  late String style;
  late bool enabled;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.botName);
    welcomeController =
        TextEditingController(text: widget.welcomeMessage);
    fallbackController =
        TextEditingController(text: widget.fallbackMessage);
    style = widget.replyStyle;
    enabled = widget.botEnabled;
  }

  @override
  void dispose() {
    nameController.dispose();
    welcomeController.dispose();
    fallbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'تخصيص المساعد الذكي',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('تفعيل الشات بوت'),
          subtitle: const Text('التحكم في استقبال المحادثات التجريبية'),
          value: enabled,
          onChanged: (value) => setState(() => enabled = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'اسم المساعد'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: welcomeController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'رسالة الترحيب'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: fallbackController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'رسالة عدم معرفة الإجابة',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: style,
          decoration: const InputDecoration(labelText: 'أسلوب الرد'),
          items: const [
            DropdownMenuItem(value: 'احترافي', child: Text('احترافي')),
            DropdownMenuItem(value: 'ودود', child: Text('ودود')),
            DropdownMenuItem(value: 'مختصر', child: Text('مختصر')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => style = value);
          },
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            widget.onSave(
              nameController.text.trim(),
              welcomeController.text.trim(),
              fallbackController.text.trim(),
              style,
              enabled,
            );
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('حفظ الإعدادات'),
        ),
        const SizedBox(height: 12),
        const Text(
          'ملاحظة: اختيار أسلوب الرد محفوظ كإعداد فقط في هذه النسخة. '
          'تطبيق أسلوب ذكي فعلي يتطلب منطق رد إضافياً أو ربط نموذج ذكاء اصطناعي.',
        ),
      ],
    );
  }
}
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0F3EB),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class ChannelCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String status;

  const ChannelCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
          ],
        ),
      ),
    );
  }
}
