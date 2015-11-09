# MiniPascal_compiler
The compiler of MiniPascal.

## Use it in VS2015:
### Configuration
项目处右键---属性

* 常规---字符集---设为“使用多字符字符集”

* C/C++---预处理器---预处理器定义---  
WIN32;_DEBUG;_CONSOLE;_CRT_SECURE_NO_WARNINGS;%(PreprocessorDefinitions)
  
* 生成事件---预先生成事件---  
  win_flex -o ast_lex.c --wincompat ast_lex.l  
  win_bison -o ast_yacc.c ast_yacc.y  
  
* 配置环境变量，把win_flex和win_bison路径加入到环境变量里。  
也可以使用如下的bat文件：  
set path=路径;%path%  
start 项目名.sln  

### Files Description
* ast_lex.l  
词法分析器，用win_flex生成.c文件，
