import{createClient}from'@supabase/supabase-js';

const SUPABASE_URL='https://uzpduwajpybexzkcyzag.supabase.co';
// ↓ 메모장에 복사해 둔 anon key (eyJhbGci... 로 시작하는 긴 것)를 붙여넣으세요
const SUPABASE_KEY='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6cGR1d2FqcHliZXh6a2N5emFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQxNTI5MTIsImV4cCI6MjA5OTcyODkxMn0.mRhTBhGfA-_WXcnZSgbNe2aQeyfWfz_awqDZe3lyy84';

export const supabase=createClient(SUPABASE_URL,SUPABASE_KEY);

// camelCase → snake_case 변환 (예: teacherId → teacher_id)
const toSC=s=>s.replace(/([A-Z])/g,'_$1').toLowerCase();
// snake_case → camelCase 변환 (예: teacher_id → teacherId)
const toCC=s=>s.replace(/_([a-z])/g,(_,c)=>c.toUpperCase());

// JS 객체 키를 snake_case로 변환 (DB 저장용)
export const toSnake=obj=>{
  if(!obj||typeof obj!=='object'||Array.isArray(obj))return obj;
  const result={};
  for(const[k,v]of Object.entries(obj)){
    if(k==='created_at'||k==='createdAt')continue; // Supabase 자동 생성 필드 제외
    result[toSC(k)]=v;
  }
  return result;
};

// DB에서 받은 snake_case 키를 camelCase로 변환 (앱 사용용)
export const toCamel=obj=>{
  if(!obj||typeof obj!=='object'||Array.isArray(obj))return obj;
  const result={};
  for(const[k,v]of Object.entries(obj)){
    if(k==='created_at')continue; // created_at은 앱에서 안 씀
    result[toCC(k)]=v;
  }
  return result;
};

// Supabase 테이블에 데이터 저장/업데이트 (upsert)
export async function dbSync(table,rows){
  if(!Array.isArray(rows)||rows.length===0)return;
  try{
    const data=rows.map(toSnake);
    const{error}=await supabase.from(table).upsert(data,{onConflict:'id'});
    if(error)console.warn('[Supabase] 저장 오류:',table,error.message);
  }catch(e){
    console.warn('[Supabase] dbSync 실패:',table,e.message);
  }
}

// Supabase 테이블에서 데이터 불러오기
export async function dbLoad(table){
  try{
    const{data,error}=await supabase.from(table).select('*');
    if(error)throw error;
    return(data||[]).map(toCamel);
  }catch(e){
    console.warn('[Supabase] dbLoad 실패:',table,e.message);
    return null;
  }
}
