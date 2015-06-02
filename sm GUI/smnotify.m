function smnotify(varargin)
% smnotify(subject,message) or smnotify(subject,message,filename)
%   notifies all users with the notifyon tag set to 1
% smnotify(subject,message,filename,user1,user2,...)
%   notifies user1, user2, ... 
%
% notification tool for special measure.  a global variable named smaux
% must exist, with the following user structure:
% smaux
%   .users(i) %length = number of users
%       .name = 'Amir'
%       .cell = '###-###-####'
%       .carrier = 'Verizon' % or some other carrier from send_text_message
%       .email = 'name@domain.com'
%       .notify = {'email' 'sms} %or some subset of these
%       .notifyon = 1 %or 0 if this user shouldn't be notified
%

global smaux;
if nargin<=2
    if nargin<2
        body='';
        if nargin==0
            subject='Runs Complete. Check Experiment.';
        else
            subject=varargin{1};
        end
    else
        body=varargin{2};
        subject=varargin{1};
    end
    for i=1:length(smaux.users)
        if smaux.users(i).notifyon
            for j=1:length(smaux.users(i).notify)
                switch smaux.users(i).notify{j}
                    case 'email'
                        sendmail(smaux.users(i).email,subject,body,[]);
                    case 'sms'
                        send_text_message(smaux.users(i).cell,smaux.users(i).carrier,subject,body);
                end
            end
        end
    end
elseif nargin==3
    for i=1:length(smaux.users)
        if smaux.users(i).notifyon
            for j=1:length(smaux.users(i).notify)
                switch smaux.users(i).notify{j}
                    case 'email'
                        sendmail(smaux.users(i).email,varargin{1},varargin{2},varargin{3});
                    case 'sms'
                        send_text_message(smaux.users(i).cell,smaux.users(i).carrier,varargin{1},varargin{2});
                end
            end
        end
    end
else
    for i=4:nargin
        for k=1:length(smaux.users)
            if strcmp(smaux.users(k).name,varargin{i})
                m=k;
            end
        end
        
        for j=1:length(smaux.users(m).notify)
            switch smaux.users(m).notify{j}
                case 'email'
                    sendmail(smaux.users(m).email,varargin{1},varargin{2},varargin{3});
                case 'sms'
                    send_text_message(smaux.users(m).cell,smaux.users(m).carrier,varargin{1},varargin{2});
            end
        end
    end
end