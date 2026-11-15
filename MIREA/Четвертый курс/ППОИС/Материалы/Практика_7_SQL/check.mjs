import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const {PGlite}=await import(process.env.PGLITE_MODULE || '@electric-sql/pglite');
const base=process.argv[2] ? path.resolve(process.argv[2]) : path.dirname(fileURLToPath(import.meta.url));
const db=new PGlite();
const result={engine:(await db.query('SELECT version()')).rows[0].version,steps:[],counts:[],queries:[],checks:[]};
try {
  for (const name of ['01_DDL_схема.sql','02_Тестовые_данные.sql','03_DCL_права.sql']) {
    const outcomes=await db.exec(await fs.readFile(path.join(base,name),'utf8'));
    result.steps.push({file:name,statements:outcomes.length,result:'OK'});
  }
  for(const row of (await db.query("SELECT tablename FROM pg_tables WHERE schemaname='crm' ORDER BY tablename")).rows){
    result.counts.push({table:row.tablename,rows:Number((await db.query(`SELECT count(*) AS n FROM crm.${row.tablename}`)).rows[0].n)});
  }
  const queries=JSON.parse(await fs.readFile(path.join(base,'запросы.json'),'utf8'));
  for(const [id,title,sql] of queries) result.queries.push({id,title,sql,rows:(await db.query(sql)).rows});
  const uid=n=>'00000000-0000-4000-8000-'+String(n).padStart(12,'0');
  async function check(name,sql,state=null,role=null,expect=null){
    await db.exec('BEGIN');
    try {
      if(role) await db.exec('SET LOCAL ROLE '+role);
      let actual=null,rows=null;
      try { rows=(await db.query(sql)).rows; } catch(e){actual=e.code;}
      const ok=actual===state && (!expect || expect(rows));
      result.checks.push({name,role:role||'владелец',expected:state||'успех',actual:actual||'успех',ok});
      if(!ok) throw new Error('Проверка не пройдена: '+name+' '+JSON.stringify({actual,state,rows}));
    } finally {await db.exec('ROLLBACK');}
  }
  await check('Повторный ИНН',`INSERT INTO crm.client(id,inn,name) VALUES ('${uid(990)}','0000000001','ТЕСТ ПОВТОРА')`,'23505');
  await check('Несуществующий клиент',`INSERT INTO crm.contact(id,client_id,full_name,email) VALUES ('${uid(990)}','${uid(999)}','ТЕСТ','a@example.invalid')`,'23503');
  await check('Отрицательное количество',`INSERT INTO crm.offer_line VALUES ('${uid(55)}',2,'${uid(41)}',-1,100,0,'RUB','month')`,'23514');
  await check('Скидка больше 100%',`UPDATE crm.offer_line SET discount_pct=101 WHERE offer_id='${uid(55)}'`,'23514');
  await check('Повтор номера позиции внутри КП',`INSERT INTO crm.offer_line SELECT * FROM crm.offer_line WHERE offer_id='${uid(55)}'`,'23505');
  await check('Повтор версии КП',`INSERT INTO crm.offer(id,deal_id,author_id,version_no,status) VALUES ('${uid(990)}','${uid(32)}','${uid(1)}',2,'draft')`,'23505');
  await check('Самосогласование',`INSERT INTO crm.approval(id,offer_id,approver_id,decision) VALUES ('${uid(990)}','${uid(55)}','${uid(2)}','approved')`,'23514');
  await check('Договор по несогласованному КП',`INSERT INTO crm.contract(id,offer_id,number,status) VALUES ('${uid(990)}','${uid(55)}','TEST-ERROR','draft')`,'23514');
  await check('Подписание без файла',`UPDATE crm.contract SET status='signed',signed_at='2026-10-28' WHERE id='${uid(73)}'`,'23514');
  await check('Заказ по неподписанному договору',`INSERT INTO crm.service_order(id,contract_id,request_key,status) VALUES ('${uid(990)}','${uid(73)}','${uid(991)}','created')`,'23514');
  await check('Повтор ключа заказа',`INSERT INTO crm.service_order(id,contract_id,request_key,status) VALUES ('${uid(990)}','${uid(71)}','${uid(181)}','created')`,'23505');
  await check('Повтор внешнего события',`INSERT INTO crm.status_event(id,order_id,external_event_id,status) VALUES ('${uid(990)}','${uid(81)}','TEST-EVT-001','sent')`,'23505');
  await check('Читатель читает представление','SELECT * FROM crm.v_offer_amount',null,'crm_reader',r=>r.length===6);
  await check('Читатель не читает контакты','SELECT * FROM crm.contact','42501','crm_reader');
  await check('Менеджер не пишет решения',`INSERT INTO crm.approval(id,offer_id,approver_id,decision) VALUES ('${uid(990)}','${uid(55)}','${uid(3)}','approved')`,'42501','crm_sales');
  await check('Администратор не пишет решения',`INSERT INTO crm.approval(id,offer_id,approver_id,decision) VALUES ('${uid(990)}','${uid(55)}','${uid(3)}','approved')`,'42501','crm_admin');
  await check('Согласующий записывает решение',`INSERT INTO crm.approval(id,offer_id,approver_id,decision) VALUES ('${uid(990)}','${uid(55)}','${uid(3)}','approved')`,null,'crm_approver');
  await check('Менеджер не изменяет аудит',"UPDATE crm.audit_event SET action='tamper'",'42501','crm_sales');
  await check('Сумма ежемесячного КП: 12000 RUB',`SELECT amount FROM crm.v_offer_amount WHERE offer_id='${uid(52)}'`,null,null,r=>r.length===1 && Number(r[0].amount)===12000);
  await check('Воронка содержит все 6 сделок','SELECT count(*)::int AS n FROM crm.deal',null,null,r=>r[0].n===6);
  await check('Разные периоды не суммируются',`SELECT billing_period,amount FROM crm.v_offer_amount WHERE offer_id='${uid(53)}' ORDER BY billing_period`,null,null,r=>r.length===2 && Number(r[0].amount)===17100 && Number(r[1].amount)===5000);
  await check('Контакт без канала связи',`UPDATE crm.contact SET email=NULL,phone=NULL WHERE id='${uid(21)}'`,'23514');
  await check('Решение без прикладной роли согласующего',`INSERT INTO crm.approval(id,offer_id,approver_id,decision) VALUES ('${uid(990)}','${uid(55)}','${uid(1)}','approved')`,'23514');
  await check('Договор без положительного решения',`DO $$ BEGIN DELETE FROM crm.approval WHERE offer_id='${uid(53)}'; UPDATE crm.contract SET number='TEST-NO-DECISION' WHERE id='${uid(73)}'; END $$;`,'23514');
  await check('Округление каждой позиции до суммирования',`DO $$ BEGIN UPDATE crm.offer_line SET quantity=1,unit_price=0.05,discount_pct=90 WHERE offer_id='${uid(52)}'; IF (SELECT amount FROM crm.v_offer_amount WHERE offer_id='${uid(52)}')<>0.02 THEN RAISE EXCEPTION 'Ошибка округления'; END IF; END $$;`);
  result.checkedAt='2026-11-04';
  await fs.writeFile(path.join(base,'Результаты_проверки.json'),JSON.stringify(result,null,2));
  for(const q of result.queries){
    const keys=Object.keys(q.rows[0]||{});
    const quote=v=>'"'+String(v??'').replaceAll('"','""')+'"';
    await fs.writeFile(path.join(base,q.id+'_результат.csv'),'\uFEFF'+[keys.map(quote).join(';'),...q.rows.map(r=>keys.map(k=>quote(r[k])).join(';'))].join('\r\n'));
  }
  const blob=await db.dumpDataDir();
  await fs.writeFile(path.join(base,'БД_PGlite.tar.gz'),Buffer.from(await blob.arrayBuffer()));
  console.log(JSON.stringify({engine:result.engine,tables:result.counts.length,rows:result.counts.reduce((s,r)=>s+r.rows,0),checks:result.checks.length,passed:result.checks.filter(t=>t.ok).length}));
} finally {await db.close();}
