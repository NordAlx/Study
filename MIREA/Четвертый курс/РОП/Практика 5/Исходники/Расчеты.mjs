import fs from 'node:fs/promises';
import path from 'node:path';
import {Workbook,SpreadsheetFile} from '@oai/artifact-tool';
const root=path.dirname(new URL(import.meta.url).pathname).replace(/^\/([A-Za-z]:)/,'$1');
const wb=Workbook.create();
const names=['Показатели','Предложение','Сделки','Подключения','Продления'];
const sh=Object.fromEntries(names.map(n=>[n,wb.worksheets.add(n)]));
const serial=date=>date.getTime()/86400000+25569;
const d=(day,h=0,month=0)=>serial(new Date(Date.UTC(2026,month,day,h)));
for(const [name,s] of Object.entries(sh)){
 s.showGridLines=false;s.getRange('A1:K30').format.font={name:'Arial',size:11,color:'#17212B'};
 s.getRange('A1:K30').format.rowHeight=25;s.getRange('A1:K30').format.verticalAlignment='center';
 s.getRange('A1:K30').format.columnWidth=18;s.getRange('A1').values=[[name+' сопровождения продаж']];s.getRange('A1').format.font={name:'Arial',size:16,bold:true};
 s.getRange('A2').values=[['Учебные данные. Пример не содержит показателей или тарифов компании.']];
 s.getRange('A2').format.font={italic:true,size:10};
}
function header(s,range){s.getRange(range).format={fill:'#263746',font:{name:'Arial',size:11,color:'#FFFFFF',bold:true},wrapText:true,rowHeight:42,horizontalAlignment:'center',verticalAlignment:'center'};}
function input(s,range){s.getRange(range).format.fill='#FFF6DD';}
function numeric(s,range,fmt='#,##0.00'){s.getRange(range).setNumberFormat(fmt);s.getRange(range).format.horizontalAlignment='right';}
const out=sh['Показатели'];
out.getRange('A4:D4').values=[['Начало периода',d(1),'Конец не включён',d(1,0,1)]];out.getRange('B4').setNumberFormat('dd.mm.yyyy');out.getRange('D4').setNumberFormat('dd.mm.yyyy');input(out,'B4');input(out,'D4');
out.getRange('A6:D10').values=[['Показатель','Числитель','Знаменатель','Результат'],['Конверсия закрытых сделок',null,null,null],['Время подключения, ч',null,null,null],['Подключения в срок',null,null,null],['Продления своевременно',null,null,null]];header(out,'A6:D6');out.getRange('A:A').format.columnWidth=37;out.getRange('B:D').format.columnWidth=22;
out.getRange('A12').values=[['Период [начало, конец). Даты и время примера заданы по Москве.']];out.getRange('A13').values=[['Жёлтые ячейки — входные данные. Остальные значения рассчитываются.']];
out.getRange('A15').values=[['Конверсия: только WON/LOST, закрытые в периоде.']];out.getRange('A16').values=[['Время и срок: одна выборка DONE/CONNECT с завершением в периоде.']];out.getRange('A17').values=[['Продления: все прежние окончания в периоде, включая отказы.']];out.getRange('A18').values=[['Пустая выборка: «нет данных». Ошибочные даты блокируют показатель.']];
const cp=sh['Предложение'];cp.getRange('A4:B6').values=[['Абонентская плата, руб./мес.',null],['Разовые услуги, руб.',null],['Первый полный месяц и разовые услуги, руб.',null]];cp.getRange('A4:A6').format.font.bold=true;
cp.getRange('A8:H10').values=[['Продукт','Кол-во','Цена/мес.','Скидка','Разовая цена','Сумма/мес.','Разовая сумма','Проверка'],['Корпоративная связь',25,450,0.1,0,null,null,null],['Канал передачи данных',1,12000,0.05,5000,null,null,null]];header(cp,'A8:H8');cp.getRange('A:A').format.columnWidth=48;cp.getRange('B:H').format.columnWidth=19;input(cp,'B9:E10');numeric(cp,'C9:C10');numeric(cp,'D9:D10','0.0%');numeric(cp,'E9:G10');
for(let r=9;r<=10;r++){
 cp.getRange(`H${r}`).formulas=[[`=IF(OR(NOT(ISNUMBER(B${r})),NOT(ISNUMBER(C${r})),NOT(ISNUMBER(D${r})),NOT(ISNUMBER(E${r})),B${r}<=0,C${r}<0,E${r}<0,D${r}<0,D${r}>1),"Ошибка","OK")`]];
 cp.getRange(`F${r}:G${r}`).formulas=[[`=IF(H${r}<>"OK","Ошибка",ROUND(B${r}*C${r}*(1-D${r}),2))`,`=IF(H${r}<>"OK","Ошибка",ROUND(B${r}*E${r},2))`]];
}
cp.getRange('B4:B6').formulas=[['=IF(COUNTIFS(H9:H10,"Ошибка")>0,"Ошибка данных",SUM(F9:F10))'],['=IF(COUNTIFS(H9:H10,"Ошибка")>0,"Ошибка данных",SUM(G9:G10))'],['=IF(COUNTIFS(H9:H10,"Ошибка")>0,"Ошибка данных",SUM(B4:B5))']];numeric(cp,'B4:B6');cp.getRange('B4:B6').format.font.bold=true;
cp.getRange('A13').values=[['Скидка действует только на абонентскую цену. НДС не рассчитывается.']];cp.getRange('A14').values=[['Денежные суммы строк округляются до 2 знаков до суммирования.']];
cp.getRange('D9:D10').dataValidation={rule:{type:'decimal',operator:'between',formula1:0,formula2:1}};
const deals=sh['Сделки'];deals.getRange('A5:H5').values=[['Код','Стадия','Открыта','Закрыта','Причина проигрыша','В периоде','Успешная','Проверка']];header(deals,'A5:H5');
const dealRows=Array.from({length:10},(_,i)=>[`DL-2026-${String(i+1).padStart(6,'0')}`,i<6?'WON':i<8?'LOST':'PROPOSAL',d(1),i<8?d(5+i):null,i>=6&&i<8?'Учебный отказ':null,null,null,null]);deals.getRange('A6:H15').values=dealRows;input(deals,'A6:E15');deals.getRange('C6:D15').setNumberFormat('dd.mm.yyyy hh:mm');deals.getRange('A:A').format.columnWidth=25;deals.getRange('C:D').format.columnWidth=24;deals.getRange('E:E').format.columnWidth=25;
for(let r=6;r<=15;r++){
 deals.getRange(`H${r}`).formulas=[[`=IF(OR(NOT(ISNUMBER(C${r})),AND(OR(B${r}="WON",B${r}="LOST"),NOT(ISNUMBER(D${r}))),AND(ISNUMBER(D${r}),D${r}<C${r})),"Ошибка","OK")`]];
 deals.getRange(`F${r}:G${r}`).formulas=[[`=IF(AND(H${r}="OK",OR(B${r}="WON",B${r}="LOST"),ISNUMBER(D${r}),D${r}>='Показатели'!$B$4,D${r}<'Показатели'!$D$4),1,0)`,`=IF(AND(F${r}=1,B${r}="WON"),1,0)`]];
}
deals.getRange('B6:B15').dataValidation={rule:{type:'list',values:['NEW','QUALIFIED','PROPOSAL','CONTRACT','WON','LOST']}};deals.freezePanes.freezeRows(5);
const req=sh['Подключения'];req.getRange('A5:J5').values=[['Код','Тип','Статус','Зарегистрирована','Плановый срок','Завершена','Длительность, ч','В выборке','В срок','Проверка']];header(req,'A5:J5');
req.getRange('A6:J13').values=[
 ['RQ-2026-000001','CONNECT','DONE',d(2),d(4,12),d(4),null,null,null,null],
 ['RQ-2026-000002','CONNECT','DONE',d(5),d(8),d(8),null,null,null,null],
 ['RQ-2026-000003','CONNECT','DONE',d(10),d(13),d(14),null,null,null,null],
 ['RQ-2026-000004','CONNECT','DONE',d(20),d(22),d(21),null,null,null,null],
 ['RQ-2026-000005','CONNECT','FAILED',d(11),d(14),d(12),null,null,null,null],
 ['RQ-2026-000006','CONNECT','IN_PROGRESS',d(25),d(30),null,null,null,null,null],
 ['RQ-2026-000007','CHANGE','DONE',d(10),d(13),d(11),null,null,null,null],
 ['RQ-2026-000008','CONNECT','DONE',d(30),d(1,0,1),d(1,0,1),null,null,null,null]
];input(req,'A6:F13');req.getRange('A:A').format.columnWidth=25;req.getRange('C:C').format.columnWidth=21;req.getRange('D:F').format.columnWidth=24;req.getRange('D6:F13').setNumberFormat('dd.mm.yyyy hh:mm');numeric(req,'G6:G13','0.0');
for(let r=6;r<=13;r++){
 req.getRange(`J${r}`).formulas=[[`=IF(OR(NOT(ISNUMBER(D${r})),NOT(ISNUMBER(E${r})),E${r}<D${r},AND(OR(C${r}="DONE",C${r}="FAILED",C${r}="CANCELLED"),NOT(ISNUMBER(F${r}))),AND(ISNUMBER(F${r}),F${r}<D${r})),"Ошибка","OK")`]];
 req.getRange(`G${r}:I${r}`).formulas=[[`=IF(J${r}<>"OK","Ошибка",IF(AND(B${r}="CONNECT",C${r}="DONE",ISNUMBER(F${r})),24*(F${r}-D${r}),""))`,`=IF(AND(J${r}="OK",B${r}="CONNECT",C${r}="DONE",ISNUMBER(F${r}),F${r}>='Показатели'!$B$4,F${r}<'Показатели'!$D$4),1,0)`,`=IF(AND(H${r}=1,F${r}<=E${r}),1,0)`]];
}req.freezePanes.freezeRows(5);
const renew=sh['Продления'];renew.getRange('A5:H5').values=[['Договор','Прежний конец','Решение','Решение принято','Новый конец','В периоде','В срок','Проверка']];header(renew,'A5:H5');
renew.getRange('A6:H9').values=[['CT-2026-000001',d(25),'ACCEPTED',d(20,12),serial(new Date(Date.UTC(2027,0,25))),null,null,null],['CT-2026-000002',d(28),'ACCEPTED',d(21,12),serial(new Date(Date.UTC(2027,0,28))),null,null,null],['CT-2026-000003',d(29),'DECLINED',d(27,12),null,null,null,null],['CT-2026-000004',d(31),'ACCEPTED',d(31,12),serial(new Date(Date.UTC(2027,0,31))),null,null,null]];input(renew,'A6:E9');renew.getRange('A:A').format.columnWidth=25;renew.getRange('B:E').format.columnWidth=24;renew.getRange('B6:B9').setNumberFormat('dd.mm.yyyy');renew.getRange('D6:E9').setNumberFormat('dd.mm.yyyy hh:mm');
for(let r=6;r<=9;r++){
 renew.getRange(`H${r}`).formulas=[[`=IF(OR(NOT(ISNUMBER(B${r})),AND(C${r}<>"PENDING",NOT(ISNUMBER(D${r}))),AND(C${r}="ACCEPTED",OR(NOT(ISNUMBER(E${r})),E${r}<=B${r}))),"Ошибка","OK")`]];
 renew.getRange(`F${r}:G${r}`).formulas=[[`=IF(AND(H${r}="OK",B${r}>='Показатели'!$B$4,B${r}<'Показатели'!$D$4),1,0)`,`=IF(AND(F${r}=1,C${r}="ACCEPTED",ISNUMBER(D${r}),INT(D${r})<=B${r},E${r}>B${r}),1,0)`]];
}renew.freezePanes.freezeRows(5);
out.getRange('B7:C10').formulas=[['=SUM(\'Сделки\'!G6:G15)','=SUM(\'Сделки\'!F6:F15)'],['=SUMIFS(\'Подключения\'!G6:G13,\'Подключения\'!H6:H13,1)','=SUM(\'Подключения\'!H6:H13)'],['=SUM(\'Подключения\'!I6:I13)','=SUM(\'Подключения\'!H6:H13)'],['=SUM(\'Продления\'!G6:G9)','=SUM(\'Продления\'!F6:F9)']];
for(let r=7;r<=10;r++){
 const [s,range]=r===7?['Сделки','H6:H15']:r===10?['Продления','H6:H9']:['Подключения','J6:J13'];
 out.getRange(`D${r}`).formulas=[[`=IF(OR(NOT(ISNUMBER(B4)),NOT(ISNUMBER(D4)),D4<=B4),"Ошибка периода",IF(COUNTIFS('${s}'!${range},"Ошибка")>0,"Ошибка данных",IF(C${r}=0,"нет данных",B${r}/C${r})))`]];
}numeric(out,'B7:C10','0');numeric(out,'D7','0.0%');numeric(out,'D8','0.0');numeric(out,'D9:D10','0.0%');out.getRange('D7:D10').format.font.bold=true;
for(const [name,s]of Object.entries(sh)){
 const range=name==='Предложение'?'H9:H10':name==='Сделки'?'H6:H15':name==='Подключения'?'J6:J13':name==='Продления'?'H6:H9':null;
 if(range)s.getRange(range).conditionalFormats.add('containsText',{text:'Ошибка',format:{fill:'#FCE4D6',font:{color:'#9C0006',bold:true}}});
}
wb.recalculate();
function num(s,c){return sh[s].getRange(c).values[0][0];}
function assertValue(s,c,expected){const v=num(s,c);if(typeof expected==='number'?Math.abs(v-expected)>1e-8:v!==expected)throw new Error(`${s}!${c}: ${v} != ${expected}`);}
assertValue('Предложение','B4',21525);assertValue('Предложение','B5',5000);assertValue('Предложение','B6',26525);
for(const [c,v]of [['D7',.75],['D8',60],['D9',.75],['D10',.75]])assertValue('Показатели',c,v);
deals.getRange('B6').values=[['LOST']];wb.recalculate();assertValue('Показатели','D7',.625);deals.getRange('B6').values=[['WON']];
cp.getRange('B9').values=[[26]];wb.recalculate();assertValue('Предложение','B4',21930);cp.getRange('B9').values=[[25]];
out.getRange('B4').values=[[serial(new Date(Date.UTC(2030,0,1)))]];out.getRange('D4').values=[[serial(new Date(Date.UTC(2030,1,1)))]];wb.recalculate();for(const c of ['D7','D8','D9','D10'])assertValue('Показатели',c,'нет данных');out.getRange('B4').values=[[d(1)]];out.getRange('D4').values=[[d(1,0,1)]];
wb.recalculate();
out.getRange('B4').setNumberFormat('dd.mm.yyyy');out.getRange('D4').setNumberFormat('dd.mm.yyyy');
const errorScan=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:30},maxChars:2000});
await fs.writeFile(path.join(root,'qa','workbook_errors.json'),JSON.stringify(errorScan));
const result={monthly:num('Предложение','B4'),one_time:num('Предложение','B5'),first_period:num('Предложение','B6'),conversion:num('Показатели','D7'),connection_hours:num('Показатели','D8'),on_time:num('Показатели','D9'),renewal:num('Показатели','D10'),tests:['Базовый пример','Изменение исходной сделки','Изменение количества позиции','Пустой период','Граница периода и решение в последний день']};
await fs.writeFile(path.join(root,'calculation_results.json'),JSON.stringify(result,null,2));
for(const [name,range]of [['Показатели','A1:E18'],['Предложение','A1:H15'],['Сделки','A1:H16'],['Подключения','A1:J14'],['Продления','A1:H10']]){
 const image=await wb.render({sheetName:name,range,scale:1.5,format:'png'});await fs.writeFile(path.join(root,'qa',`xlsx_${name}.png`),new Uint8Array(await image.arrayBuffer()));
}
await(await SpreadsheetFile.exportXlsx(wb)).save(path.join(root,'deliverables','Практика 5','Расчеты.xlsx'));
console.log(JSON.stringify(result));
