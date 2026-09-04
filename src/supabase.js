import{createClient}from'@supabase/supabase-js';

const SUPABASE_URL=import.meta.env.VITE_SUPABASE_URL||'https://uzpduwajpybexzkcyzag.supabase.co';
const SUPABASE_KEY=import.meta.env.VITE_SUPABASE_KEY||'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6cGR1d2FqcHliZXh6a2N5emFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQxNTI5MTIsImV4cCI6MjA5OTcyODkxMn0.mRhTBhGfA-_WXcnZSgbNe2aQeyfWfz_awqDZe3lyy84';

export const supabase=createClient(SUPABASE_URL,SUPABASE_KEY);

// ── 학원 ID (다중 학원 데이터 분리) ─────────────────────────────────────────
// 각 학원은 고유한 academy_id를 가짐 → 다른 학원 데이터에 접근 불가
let _academyId=null;
export const setAcademyId=(id)=>{_academyId=id;};

// ── Supabase Auth 함수 ───────────────────────────────────────────────────────
export async function authSignUp(email,password){
  const{data,error}=await supabase.auth.signUp({email,password});
  if(error)throw error;
  return data;
}
export async function authSignIn(email,password){
  const{data,error}=await supabase.auth.signInWithPassword({email,password});
  if(error)throw error;
  return data;
}
export async function authSignOut(){
  await supabase.auth.signOut();
}
export async function authGetSession(){
  const{data:{session}}=await supabase.auth.getSession();
  return session;
}

// camelCase → snake_case (예: teacherId → teacher_id)
const toSC=s=>s.replace(/([A-Z])/g,'_$1').toLowerCase();
// snake_case → camelCase (예: teacher_id → teacherId)
const toCC=s=>s.replace(/_([a-z])/g,(_,c)=>c.toUpperCase());

// JS 객체 키를 snake_case로 변환 (DB 저장용)
export const toSnake=obj=>{
  if(!obj||typeof obj!=='object'||Array.isArray(obj))return obj;
  const result={};
  for(const[k,v]of Object.entries(obj)){
    if(k==='created_at'||k==='createdAt')continue;
    result[toSC(k)]=v;
  }
  return result;
};

// DB에서 받은 snake_case 키를 camelCase로 변환 (앱 사용용)
export const toCamel=obj=>{
  if(!obj||typeof obj!=='object'||Array.isArray(obj))return obj;
  const result={};
  for(const[k,v]of Object.entries(obj)){
    if(k==='created_at'||k==='academy_id')continue; // DB 전용 필드 제외
    result[toCC(k)]=v;
  }
  return result;
};

// Supabase 테이블에 데이터 저장/업데이트 (academy_id 자동 포함)
export async function dbSync(table,rows){
  if(!Array.isArray(rows)||rows.length===0)return;
  if(!_academyId){console.warn('[Supabase] academyId 없음 - 저장 스킵:',table);return;}
  try{
    const data=rows.map(r=>({...toSnake(r),academy_id:_academyId}));
    const{error}=await supabase.from(table).upsert(data,{onConflict:'id'});
    if(error)console.warn('[Supabase] 저장 오류:',table,error.message);
  }catch(e){
    console.warn('[Supabase] dbSync 실패:',table,e.message);
  }
}

// Supabase 테이블에서 데이터 불러오기 (해당 학원 데이터만)
export async function dbLoad(table){
  if(!_academyId){console.warn('[Supabase] academyId 없음 - 로드 스킵:',table);return null;}
  try{
    const{data,error}=await supabase.from(table).select('*').eq('academy_id',_academyId);
    if(error)throw error;
    return(data||[]).map(toCamel);
  }catch(e){
    console.warn('[Supabase] dbLoad 실패:',table,e.message);
    return null;
  }
}
