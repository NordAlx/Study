await figma.loadFontAsync({family:'Inter',style:'Regular'});
await figma.loadFontAsync({family:'Inter',style:'Medium'});
await figma.loadFontAsync({family:'Inter',style:'Semi Bold'});
await figma.loadFontAsync({family:'Inter',style:'Bold'});
const buttonSet=await figma.importComponentSetByKeyAsync('cc8b558dc7d9684011b6b99ce8e6509399bc836b');
const inputSet=await figma.importComponentSetByKeyAsync('c28150b04d333d34ed9d2b77abd9f2f54e1a878a');
const bg=await figma.variables.importVariableByKeyAsync('a4865545b526a5b3399a512667f40c9efe0c2fc4');
const secondary=await figma.variables.importVariableByKeyAsync('34f184ba91e9ebb52258b767a603f5c2c97956a2');
const textColor=await figma.variables.importVariableByKeyAsync('cf92d4e8c6a5a5ed82f024d47d11c21d5162ac3c');
const border=await figma.variables.importVariableByKeyAsync('395870afebb3397e858358930ffdd69a5ec0f73d');
const space=await figma.variables.importVariableByKeyAsync('16bc6f84b6e7e20e4234ef79030ee580ec0f4505');
const created=[]; const frames=[];const links={};
const page=figma.currentPage;page.name='Практика 4 Каркасные экраны';
function track(n){created.push(n.id);return n;}
function paint(v){return figma.variables.setBoundVariableForPaint({type:'SOLID',color:{r:1,g:1,b:1}},'color',v);}
function box(name,width,direction='VERTICAL'){
 const f=track(figma.createAutoLayout(direction));f.name=name;f.resize(width,100);f.primaryAxisSizingMode='AUTO';f.counterAxisSizingMode='FIXED';f.setBoundVariable('itemSpacing',space);f.fills=[paint(bg)];return f;
}
function txt(parent,value,width=1024,size=18,bold=false){
 const t=track(figma.createText());t.name=value.slice(0,55);t.fontName={family:'Inter',style:bold?'Bold':'Regular'};t.fontSize=size;t.characters=value;t.textAutoResize='HEIGHT';t.resize(width,Math.max(24,size+8));t.fills=[paint(textColor)];parent.appendChild(t);return t;
}
function btn(parent,value,variant='Neutral'){
 const inst=track(buttonSet.defaultVariant.createInstance());parent.appendChild(inst);inst.setProperties({'Label#2:0':value,'Variant':variant,'Has Icon Start#4:128':false,'Has Icon End#4:64':false});return inst;
}
function input(parent,label,value,width=450){
 const inst=track(inputSet.defaultVariant.createInstance());parent.appendChild(inst);inst.setProperties({'Label#280:41':label,'Value#630:14':value,'Has Description#611:20':false});inst.resize(width,inst.height);return inst;
}
function row(parent){const r=box('Строка',1030,'HORIZONTAL');parent.appendChild(r);r.counterAxisAlignItems='CENTER';return r;}
function card(parent,title){const c=box(title,1080);parent.appendChild(c);for(const p of ['paddingTop','paddingBottom','paddingLeft','paddingRight'])c.setBoundVariable(p,space);c.strokes=[paint(border)];c.strokeWeight=1;txt(c,title,1030,22,true);return c;}
function grid(parent,headers,rows,widths){
 const table=box('Таблица',1030);parent.appendChild(table);
 for(const [i,values] of [headers,...rows].entries()){
  const r=box(i===0?'Заголовок':'Запись '+i,1030,'HORIZONTAL');table.appendChild(r);r.itemSpacing=12;r.paddingTop=10;r.paddingBottom=10;if(i===0)r.fills=[paint(secondary)];r.strokes=[paint(border)];r.strokeBottomWeight=1;
  values.forEach((v,j)=>txt(r,String(v),widths[j],16,i===0));
 }
 return table;
}
function screen(code,title,role,index){
 const f=box(code+' '+title,1440,'HORIZONTAL');page.appendChild(f);f.resize(1440,1020);f.primaryAxisSizingMode='FIXED';f.x=(index%2)*1660;f.y=Math.floor(index/2)*1240;f.itemSpacing=0;f.clipsContent=true;
 const nav=box('Навигация',240);f.appendChild(nav);nav.resize(240,1020);nav.primaryAxisSizingMode='FIXED';nav.fills=[paint(secondary)];nav.paddingTop=30;nav.paddingLeft=24;nav.paddingRight=24;nav.itemSpacing=28;
 txt(nav,'Корпоративные\nпродажи',190,24,true);['Клиенты','Сделки','Предложения','Договоры','Заявки','Продления','Отчёты'].forEach(v=>txt(nav,v,185,18));
 const main=box('Содержание',1200);f.appendChild(main);main.paddingLeft=40;main.paddingRight=40;main.paddingTop=32;main.paddingBottom=32;main.itemSpacing=24;
 txt(main,code+'  '+title,1100,32,true);txt(main,role+'  •  Учебный прототип',1100,16);
 frames.push({code,id:f.id,title});links[code]=f;return {frame:f,main};
}
{
 const {main}=screen('W1','Клиенты','Менеджер',0);
 const actions=row(main);input(actions,'Поиск клиента','ИНН или наименование',650);btn(actions,'Новый клиент');
 const c=card(main,'Закреплённые клиенты');grid(c,['Код','Организация','Ответственный'],[['CL-2026-000001','Учебный клиент 01','Текущий менеджер'],['CL-2026-000002','Учебный клиент 02','Текущий менеджер'],['CL-2026-000003','Учебный клиент 03','Текущий менеджер']],[230,440,300]);
 btn(c,'Открыть карточку');txt(main,'Новый клиент: обязательны наименование и ИНН из 10 цифр. Существующий ИНН открывает карточку в пределах прав.',1050,17);
}
{
 const {main}=screen('W2','Карточка клиента и сделки','Менеджер',1);
 const c=card(main,'Учебный клиент 01');const r=row(c);input(r,'ИНН','Введите 10 цифр',450);input(r,'Контакт','Не задан',450);
 txt(c,'CL-2026-000001   •   Ответственный: текущий менеджер',1030,17);
 const d=card(main,'Сделка DL-2026-000001');txt(d,'Подключение корпоративных услуг   •   Стадия QUALIFIED',1030,20);txt(d,'История: обращение зарегистрировано, потребность уточнена.',1030,17);
 const a=row(d);btn(a,'Создать предложение');btn(a,'Новая сделка');
 const e=card(main,'Связанные материалы');txt(e,'Предложения • договоры • заявки • история изменений',1030,18);
}
function offerContent(main,approval){
 const c=card(main,'OF-2026-000001   •   Версия 1   •   '+(approval?'SUBMITTED':'DRAFT'));
 grid(c,['Позиция','Кол-во','Цена/мес.','Скидка','Сумма/мес.'],[['Корпоративная связь','25','450,00','10%','10 125,00'],['Канал передачи данных','1','12 000,00','5%','11 400,00']],[350,110,170,100,180]);
 txt(c,'Абонентская плата  21 525,00 руб./мес.\nРазовые услуги  5 000,00 руб.\nПервый полный месяц и разовые услуги  26 525,00 руб.',1030,22,true);
 txt(c,'Учебные цены. Скидка применяется только к абонентской плате. НДС в расчёт не включён.',1030,16);
 const a=row(c);if(approval){btn(a,'Согласовать');btn(a,'Отклонить');input(c,'Комментарий к решению','Введите пояснение',1000);txt(c,'Автор предложения не может согласовать собственную версию.',1030,17);}else{btn(a,'Добавить позицию');btn(a,'Сохранить черновик');btn(a,'На согласование');txt(c,'После отправки версия блокируется. Для исправлений создаётся новая версия.',1030,17);}
}
{const {main}=screen('W3','Предложение','Менеджер',2);offerContent(main,false);}
{const {main}=screen('W3b','Согласование предложения','Руководитель',3);offerContent(main,true);}
{
 const {main}=screen('W4','Договор и подключение','Менеджер / технический специалист',4);
 const c=card(main,'CT-2026-000001   •   Договор действует');txt(c,'Подписан вне ИС   •   Предложение согласовано',1030,17);const r=row(c);input(r,'Начало действия','01.01.2026',450);input(r,'Окончание','31.12.2026',450);
 const d=card(main,'Подключение RQ-2026-000001');grid(d,['Тип','Плановый срок','Исполнитель','Статус'],[['CONNECT','Учебный плановый срок','Назначенный специалист','SENT']],[160,290,290,230]);txt(d,'Исход отправки уточняется. Новое подключение повторно создавать не нужно.',1030,18);const a=row(d);btn(a,'История заявки');btn(a,'Обновить статус');
 txt(main,'Новая заявка создаётся с типом, сроком, исполнителем и основанием. До отправки доступна отмена.',1050,17);
}
{
 const {main}=screen('W5','Изменения и продление','Менеджер',5);
 const c=card(main,'Изменение услуг');const r=row(c);input(r,'Договор','CT-2026-000002',450);input(r,'Тип заявки','CHANGE',450);input(c,'Подписанное основание','Выберите документ',950);btn(c,'Создать заявку на изменение');
 const d=card(main,'Продление договора');txt(d,'Прежний срок: 31.01.2026   •   Решение PENDING',1030,18);const a=row(d);input(a,'Новый срок','Введите дату позже прежней',450);input(a,'Основание','Подписанное продление',450);const b=row(d);btn(b,'Учесть продление');btn(b,'Зафиксировать отказ');
 txt(main,'Напоминание за 30 дней. Отказ сохраняет прежний срок договора. Все даты на экране учебные.',1050,16);
}
{
 const {main}=screen('W6','Показатели сопровождения','Руководитель',6);
 const a=row(main);input(a,'Период','01.01.2026 — 31.01.2026',650);btn(a,'Рассчитать');
 const c=card(main,'Учебный пример');grid(c,['Показатель','Результат','Выборка'],[['Конверсия закрытых сделок','75%','6 успешных из 8 закрытых'],['Среднее время подключения','60 ч','4 выполненных подключения'],['Подключения в срок','75%','3 из 4 выполненных'],['Своевременные продления','75%','3 из 4 сроков договора']],[440,200,340]);
 txt(c,'Пустая выборка отображается как «нет данных». Период и подразделение применяются до расчёта.',1030,18);btn(c,'Показать детализацию');
}
return {frames,createdNodeIds:created,editableTextCount:created.length,notes:'Code Connect: N/A, проект создаётся с нуля. Существующих экранов нет. Кнопки, поля, шрифты и переменные импортированы из Simple Design System.'};
