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
 const f=track(figma.createAutoLayout(direction));f.name=name;f.resize(width,100);f.primaryAxisSizingMode=direction==='VERTICAL'?'AUTO':'FIXED';f.counterAxisSizingMode=direction==='VERTICAL'?'FIXED':'AUTO';f.setBoundVariable('itemSpacing',space);f.fills=[paint(bg)];return f;
}
function txt(parent,value,width=1024,size=18,bold=false){
 const t=track(figma.createText());t.name=value.slice(0,55);t.fontName={family:'Inter',style:bold?'Bold':'Regular'};t.fontSize=size;t.characters=value;t.textAutoResize='NONE';t.lineHeight={unit:'PIXELS',value:size*1.35};const lines=value.split('\n').reduce((s,l)=>s+Math.max(1,Math.ceil(l.length*size*0.59/width)),0);t.resize(width,Math.ceil(lines*size*1.35+3));t.fills=[paint(textColor)];parent.appendChild(t);return t;
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
 txt(nav,'Продажи\nкорпоративным\nклиентам',190,20,true);['Клиенты','Сделки','Предложения','Договоры','Заявки','Продления','Отчёты'].forEach(v=>txt(nav,v,185,18));
 const main=box('Содержание',1200);f.appendChild(main);main.paddingLeft=40;main.paddingRight=40;main.paddingTop=32;main.paddingBottom=32;main.itemSpacing=24;
 txt(main,code+'  '+title,1100,32,true);txt(main,role+'  •  Учебный прототип',1100,16);
 frames.push({code,id:f.id,title});links[code]=f;return {frame:f,main};
}
{
 const {main}=screen('W1b','Клиент и новое обращение','Менеджер',7);
 const c=card(main,'Реквизиты юридического лица');input(c,'Наименование','Введите наименование',1000);const a=row(c);input(a,'ИНН','10 цифр',450);input(a,'Контакт','Телефон или электронная почта',450);
 const d=card(main,'Обращение');input(d,'Потребность клиента','Опишите услуги и задачу клиента',1000);txt(d,'Ответственный: текущий менеджер. Новая сделка получает стадию NEW.',1030,17);const b=row(d);btn(b,'Зарегистрировать');btn(b,'Отмена');
 txt(main,'Ошибка ИНН отображается у поля. Если ИНН уже существует, система предлагает открыть доступную карточку без создания дубля.',1050,17);
}
{
 const {main}=screen('W4b','Новая заявка сопровождения','Менеджер',8);
 const c=card(main,'CT-2026-000001');const a=row(c);input(a,'Тип заявки','CONNECT',450);input(a,'Плановый срок','Дата и время',450);input(c,'Исполнитель','Выберите технического специалиста',1000);input(c,'Основание и условия','Подписанный договор, состав подключаемых услуг',1000);const b=row(c);btn(b,'Создать заявку');btn(b,'Отмена');
 txt(main,'Обязательны тип, срок, исполнитель и основание. Плановый срок не может предшествовать регистрации.',1050,17);
 txt(main,'После сохранения заявка получает NEW. Отправку подтверждает назначенный технический специалист после проверки данных.',1050,17);
}
const roots=figma.currentPage.children.filter(n=>n.type==='FRAME'&&/^W\d/.test(n.name));
const map=Object.fromEntries(roots.map(n=>[n.name.split(' ')[0],n]));
const nav={'Клиенты':'W1','Сделки':'W2','Предложения':'W3','Договоры':'W4','Заявки':'W4','Продления':'W5','Отчёты':'W6'};
async function link(n,target){if(!target||typeof n.setReactionsAsync!=='function')return;let ancestor=n;while(ancestor.parent&&ancestor.parent.type!=='PAGE')ancestor=ancestor.parent;if(ancestor.id===target.id)return;await n.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions:[{type:'NODE',destinationId:target.id,navigation:'NAVIGATE',transition:null,preserveScrollPosition:false}]}]);created.push(n.id);}
for(const root of roots){
 const sidebar=root.children[0];for(const n of sidebar.children){if(n.type==='TEXT'&&nav[n.characters])await link(n,map[nav[n.characters]]);}
 const instances=root.findAllWithCriteria({types:['INSTANCE']});
 for(const n of instances){
  const prop=Object.entries(n.componentProperties).find(([k,v])=>k.startsWith('Label#')&&v.type==='TEXT');const label=prop?prop[1].value:'';
  const dest={'Новый клиент':'W1b','Открыть карточку':'W2','Создать предложение':'W3','На согласование':'W3b','Согласовать':'W4','Создать заявку':'W4','Создать заявку на изменение':'W4b','Учесть продление':'W4','Рассчитать':'W6','Зарегистрировать':'W2'}[label];
  if(dest)await link(n,map[dest]);
 }
}
const w4=map.W4;
const history=w4.findAllWithCriteria({types:['INSTANCE']}).find(n=>Object.entries(n.componentProperties).some(([k,v])=>k.startsWith('Label#')&&v.type==='TEXT'&&v.value==='История заявки'));
if(history){const createButton=btn(history.parent,'Новая заявка');history.parent.primaryAxisSizingMode='AUTO';history.parent.layoutSizingHorizontal='HUG';history.parent.clipsContent=false;await link(createButton,map.W4b);}
return {createdNodeIds:created,frames:roots.map(n=>({id:n.id,name:n.name})),prototypeConnections:true};
