# Single source for Manage Devices / Kendo grid OOM mitigations (CDP + in-page inject).
# Keep minified IIFE in sync with browser_keywords Install Global Page Size Limiter.

GRID_OOM_PATCH_SCRIPT = r"""
(function(){
if(window.__stcGridOomPatchV2)return;
window.__stcGridOomPatchV2=1;
var PSZ=50,MAX=10000,AL=100000,MAX_TOP=150;
var K=["total","totalCount","Total","TotalCount","totalRecords","rowCount","RowCount","__count","Count","count","recordsTotal","recordsFiltered","@odata.count"];
var isArr=Array.isArray;
function C(o,d){if(d>25||!o||typeof o!="object")return;if(isArr(o)){for(var i=0;i<o.length;i++)C(o[i],d+1);return;}for(var j=0;j<K.length;j++){var n=K[j];if(Object.prototype.hasOwnProperty.call(o,n)&&typeof o[n]==="number"&&o[n]>MAX)o[n]=MAX;}for(var p in o)if(Object.prototype.hasOwnProperty.call(o,p))C(o[p],d+1);}
var JP=JSON.parse;
function capT(t){if(!t||typeof t!="string"||!t.length)return t;var c=t.charCodeAt(0);if(c!==123&&c!==91)return t;try{var z=JP(t);C(z,0);return JSON.stringify(z);}catch(e){return t;}}
JSON.parse=function(t,r){var d=JP.call(JSON,t,r);C(d,0);return d;};
function isG(u){if(!u)return 0;var l=(""+u).toLowerCase();
if(l.indexOf(".css")>0||l.indexOf(".js?")>0||l.indexOf(".png")>0||l.indexOf(".woff")>0)return 0;
return l.indexOf("/api/")>=0||l.indexOf("device")>=0||l.indexOf("subscriber")>=0||l.indexOf("customer")>=0
||l.indexOf("account")>=0||l.indexOf("sim")>=0||l.indexOf("grid")>=0||l.indexOf("odata")>=0
||l.indexOf("kendo")>=0||l.indexOf("inventory")>=0||l.indexOf("managedevice")>=0
||l.indexOf("$top")>=0||l.indexOf("%24top")>=0||l.indexOf("take=")>=0||l.indexOf("$skip")>=0
||l.indexOf("skip=")>=0||l.indexOf("/read")>=0||l.indexOf("query")>=0;}
function capTop(u){if(!u)return u;var s=(""+u).replace(/\$top=(\d+)/gi,function(m,n){var v=parseInt(n,10);return isFinite(v)&&v>MAX_TOP?"$top="+MAX_TOP:m;});
s=s.replace(/%24top=(\d+)/gi,function(m,n){var v=parseInt(n,10);return isFinite(v)&&v>MAX_TOP?"%24top="+MAX_TOP:m;});
s=s.replace(/([\?&]take=)(\d+)/gi,function(m,p,n){var v=parseInt(n,10);return isFinite(v)&&v>MAX_TOP?p+MAX_TOP:m;});
return s;}
function lim(u){if(!u)return u;u=capTop(u);var l=(""+u).toLowerCase();
if(l.indexOf("pagesize=")>=0||l.indexOf("page_size=")>=0||l.indexOf("search=")>=0)return u;
if(!isG(u))return u;
if(l.indexOf("$top=")>=0||l.indexOf("%24top=")>=0||l.indexOf("take=")>=0)return u;
return u+(((""+u).indexOf("?")>=0)?"&":"?")+"pageSize="+PSZ;}
var map=new WeakMap(),oO=XMLHttpRequest.prototype.open,oA=XMLHttpRequest.prototype.addEventListener;
XMLHttpRequest.prototype.open=function(m,u){map.set(this,u);var a=[].slice.call(arguments);a[1]=lim(u);return oO.apply(this,a);};
XMLHttpRequest.prototype.addEventListener=function(ty,fn,opt){var x=this,u=map.get(x);if(fn&&isG(u)&&(ty==="readystatechange"||ty==="load"||ty==="loadend")){var w=function(e){if(x.readyState===4){try{var g=Object.getOwnPropertyDescriptor(XMLHttpRequest.prototype,"responseText").get.call(x),mt=capT(g);if(mt!==g){Object.defineProperty(x,"responseText",{configurable:1,get:function(){return mt;}});try{Object.defineProperty(x,"response",{configurable:1,get:function(){return mt;}});}catch(z){}}}catch(e){}}return fn.apply(this,arguments);};return oA.call(this,ty,w,opt);}return oA.call(this,ty,fn,opt);};
var oF=fetch;
window.fetch=function(r,o){var u=typeof r=="string"?r:(r&&r.url?r.url:null),rq=r;if(lim(u)!==u&&u)rq=r instanceof Request?new Request(lim(u),r):lim(u);var pr=oF.call(this,rq,o);if(!isG(u||""))return pr;return pr.then(function(rs){if(!rs.ok)return rs;return rs.clone().text().then(function(t){var mt=capT(t);return mt!==t?new Response(mt,{status:rs.status,statusText:rs.statusText,headers:rs.headers}):rs;});});};
var RA=Array;
try{var PA=new Proxy(RA,{construct:function(T,a,nw){if(a.length===1&&typeof a[0]==="number"&&isFinite(a[0])&&a[0]>AL)a=[AL];return Reflect.construct(T,a,nw);}});PA.from=RA.from;PA.of=RA.of;PA.isArray=RA.isArray;PA.prototype=RA.prototype;window.Array=PA;}catch(Px){}
})();
""".strip()


def get_grid_oom_patch_script() -> str:
    """Return the minified IIFE for CDP Page.addScriptToEvaluateOnNewDocument or Execute Javascript."""
    return GRID_OOM_PATCH_SCRIPT
