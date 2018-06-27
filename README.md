# SQLiteObject_C
       说一说写这个类的初衷吧，在写项目的时候做数据持久化存储是必不可少的,所以在项目里会频繁的使用到sqlite数据库。
    虽然现在有很多相关的对sqlist C语言API封装的工具类库(比如经常在用的FMDB)，但是依然发现有一个不尽人意的地方。
       当我在使用FMDB提供的API来做查增删改等操作时，需要我们写SQL语句来执行API，这时就需要我手动的书写SQL语句字符
    串。有时我们写的SQL语句会比较复杂然后就会很容易出现SQL语句书写错误的情况，然后蛋疼的事情来了你的去检查你的S
    QL字符串倒地错哪了,费时又费脑，然后我就在思考我可不可以写一个用来描述SQL语句的工具类呢(当然工具类得达到我的预期
    才行)?，答案是肯定的SQLiteLanguage就是用来描述SQL语句的类（main文件里有实例代码）。SQLiteLanguage里定义了
    一些SQL关键字的方法，后续将会不断完善（如果有什么做的不对的地方希望得到各位的大神的提点）。
    
    使用实例：
    1.打开数据库，通过SQLITEObjectC类的单例来创建数据库连接：
    NSString *pathStr =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/School.db"];
    if (![[SQLITEObjectC share] openWithFilePath:pathStr]) {
    NSLog(@"数据库打开失败");
    }
    2.创建表，通过SQLiteLanguage来构建SQL然后通过SQLITEObjectC类的单例的-(BOOL)execSQL:(SQLiteLanguage *)sqll方法执行SQL语句：
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.CREATE.TABEL(@"Sutdent").COLUMNS(
    SQLlang.columnName(@"age").INTEGER,//列名叫age,INTEGER类型的数据,不许为空
    SQLlang.columnName(@"name").TEXT,
    SQLlang.columnName(@"ID").TEXT.NOT(@"NULL").PRIMARY.KEY(nil),//列名叫ID,TEXT类型的数据同时设置为主键,不许为空
    nil
    );
    if (![[SQLITEObjectC share] execSQL:sqll]) {
    NSLog(@"创建表失败");
    }
    3.删除表，通过SQLiteLanguage来构建SQL然后通过SQLITEObjectC类的单例的-(BOOL)execSQL:(SQLiteLanguage *)sqll方法执行SQL语句：
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.DROP.TABEL(@"Sutdent");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
    NSLog(@"删除表失败");
    }

    
