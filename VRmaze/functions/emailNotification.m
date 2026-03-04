% Script for the email notification

mail = 'goard.lab@gmail.com';
password = 'Ramon@Cajal';
host = 'smtp.gmail.com';
port  = '465';
emailto = 'lmfrancomendez@gmail.com';
subject = 'Behavior Rig 3';
message = 'Training session finished.';

setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server',host);
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.user',mail);
props.setProperty('mail.smtp.host',host);
props.setProperty('mail.smtp.port',port);
props.setProperty('mail.smtp.starttls.enable','true');
props.setProperty('mail.smtp.debug','true');
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.port',port);
props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.fallback','false');

sendmail(emailto,subject,message);

