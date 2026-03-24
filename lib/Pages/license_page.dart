import '../l10n/app_localizations.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// License information page for dependencies
class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ScaffoldPage.scrollable(
      header: PageHeader(

        leading: IconButton(
          icon: const Icon(FluentIcons.reply_alt),
          style:ButtonStyle(iconSize: WidgetStatePropertyAll(30)),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(l10n.tr('licenses')),
      ),
      children: [
        
        Expander(
          header: Text(
            'EasyCompress Assistant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BSD 3-Clause License\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Copyright (c) 2026, EasyCompressAssistant\n'
                  'All rights reserved.\n\n'
                  'Redistribution and use in source and binary forms, with or without\n'
                  'modification, are permitted provided that the following conditions are met:\n\n'
                  '1. Redistributions of source code must retain the above copyright notice, this\n'
                  '   list of conditions and the following disclaimer.\n\n'
                  '2. Redistributions in binary form must reproduce the above copyright notice,\n'
                  '   this list of conditions and the following disclaimer in the documentation\n'
                  '   and/or other materials provided with the distribution.\n\n'
                  '3. Neither the name of the copyright holder nor the names of its\n'
                  '   contributors may be used to endorse or promote products derived from\n'
                  '   this software without specific prior written permission.\n\n'
                  'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"\n'
                  'AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE\n'
                  'IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE\n'
                  'DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE\n'
                  'FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL\n'
                  'DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR\n'
                  'SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER\n'
                  'CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,\n'
                  'OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE\n'
                  'OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expander(
          header: Text(
            'Flutter Framework',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BSD 3-Clause License\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Copyright 2014 The Flutter Authors. All rights reserved.\n\n'
                  'Redistribution and use in source and binary forms, with or without modification,\n'
                  'are permitted provided that the following conditions are met:\n\n'
                  '    * Redistributions of source code must retain the above copyright\n'
                  '      notice, this list of conditions and the following disclaimer.\n'
                  '    * Redistributions in binary form must reproduce the above copyright\n'
                  '      notice, this list of conditions and the following disclaimer in the\n'
                  '      documentation and/or other materials provided with the distribution.\n'
                  '    * Neither the name of Google Inc. nor the names of its contributors may\n'
                  '      be used to endorse or promote products derived from this software\n'
                  '      without specific prior written permission.\n\n'
                  'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND\n'
                  'ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED\n'
                  'WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE\n'
                  'DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR\n'
                  'ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES\n'
                  '(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;\n'
                  'LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND\n'
                  'ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT\n'
                  '(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS\n'
                  'SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expander(
          header: Text(
            'fluent_ui',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MIT License\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Copyright (c) 2021 Bruno D\'Luka. All rights reserved.\n\n'
                  'Permission is hereby granted, free of charge, to any person obtaining a copy\n'
                  'of this software and associated documentation files (the "Software"), to deal\n'
                  'in the Software without restriction, including without limitation the rights\n'
                  'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n'
                  'copies of the Software, and to permit persons to whom the Software is\n'
                  'furnished to do so, subject to the following conditions:\n\n'
                  'The above copyright notice and this permission notice shall be included in all\n'
                  'copies or substantial portions of the Software.\n\n'
                  'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n'
                  'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n'
                  'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n'
                  'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n'
                  'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n'
                  'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n'
                  'SOFTWARE.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expander(
          header: Text(
            'archive',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MIT License\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Copyright (c) 2014 Google Inc. All rights reserved.\n\n'
                  'Permission is hereby granted, free of charge, to any person obtaining a copy\n'
                  'of this software and associated documentation files (the "Software"), to deal\n'
                  'in the Software without restriction, including without limitation the rights\n'
                  'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n'
                  'copies of the Software, and to permit persons to whom the Software is\n'
                  'furnished to do so, subject to the following conditions:\n\n'
                  'The above copyright notice and this permission notice shall be included in\n'
                  'all copies or substantial portions of the Software.\n\n'
                  'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n'
                  'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n'
                  'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n'
                  'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n'
                  'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n'
                  'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n'
                  'THE SOFTWARE.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expander(
          header: Text(
            'Other Dependencies',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '以下库均使用 BSD 3-Clause 许可证：\n\n'
                  '- permission_handler\n'
                  '- file_selector\n'
                  '- shared_preferences\n'
                  '- url_launcher\n'
                  '- flutter_local_notifications\n\n'
                  '这些库的许可证条款与本项目使用的BSD 3-Clause许可证兼容。',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}