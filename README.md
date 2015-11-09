# MiniPascal_compiler
The compiler of MiniPascal.

## Use it in VS2015:
### Configuration
项目处右键---属性---

1.常规---字符集---设为“使用多字符字符集”

2.C/C++---预处理器---预处理器定义
WIN32;_DEBUG;_CONSOLE;_CRT_SECURE_NO_WARNINGS;%(PreprocessorDefinitions)
  
3.生成事件---预先生成事件
  win_flex -o ast_lex.c --wincompat ast_lex.l
  win_bison -o ast_yacc.c ast_yacc.y
