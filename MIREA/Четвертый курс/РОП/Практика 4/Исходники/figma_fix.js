const frames=[];const changed=[];
const all=figma.currentPage.children.filter(n=>n.type==='FRAME'&&/^W\d/.test(n.name));
for(const root of all){
 const nodes=root.findAllWithCriteria({types:['TEXT','FRAME']});
 for(const n of nodes){
  if(n.type==='FRAME' && n.layoutMode==='HORIZONTAL'){
   n.primaryAxisSizingMode='FIXED';n.counterAxisSizingMode='AUTO';changed.push(n.id);
  }
  if(n.type!=='TEXT')continue;
  let p=n.parent;let instance=false;while(p&&p.id!==root.id){if(p.type==='INSTANCE'){instance=true;break;}p=p.parent;}
  if(instance)continue;
  const segments=n.getStyledTextSegments(['fontName']);
  for(const seg of segments)await figma.loadFontAsync(seg.fontName);
  if(n.characters==='Корпоративные\nпродажи'){n.characters='Продажи\nкорпоративным\nклиентам';n.fontSize=20;}
  const size=typeof n.fontSize==='number'?n.fontSize:18;
  const lines=n.characters.split('\n').reduce((s,l)=>s+Math.max(1,Math.ceil(l.length*size*0.59/n.width)),0);
  const width=n.width;n.textAutoResize='NONE';n.lineHeight={unit:'PIXELS',value:size*1.35};n.resize(width,Math.ceil(lines*size*1.35+3));changed.push(n.id);
 }
 frames.push({id:root.id,name:root.name,children:root.children.length});
}
return {mutatedNodeIds:changed,frames};
