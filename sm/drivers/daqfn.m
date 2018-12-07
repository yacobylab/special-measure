function varargout = daqfn(fn, varargin)
% function varargout = daqfn(fn, varargin)
% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


status = uint32(0);
%fprintf('Calling %s\n',fn);
[status(:), varargout{1:nargout}] = calllib('ATSApi', ['Alazar', fn], varargin{:});

if status~=512 && status ~=800
    error(sprintf('Error %s in call of %s.\n', errorcode(status), fn));
end
return

function str = errorcode(code)
ErrorCode{1}='Yes'; 
ErrorCode{512}='ApiSuccess';
ErrorCode{513}='ApiFailed';
ErrorCode{514}='ApiAccessDenied';
ErrorCode{515}='ApiDmaChannelUnavailable';
ErrorCode{516}='ApiDmaChannelInvalid';
ErrorCode{517}='ApiDmaChannelTypeError';
ErrorCode{518}='ApiDmaInProgress';
ErrorCode{519}='ApiDmaDone';
ErrorCode{520}='ApiDmaPaused';
ErrorCode{521}='ApiDmaNotPaused';
ErrorCode{522}='ApiDmaCommandInvalid';
ErrorCode{523}='ApiDmaManReady';
ErrorCode{524}='ApiDmaManNotReady';
ErrorCode{525}='ApiDmaInvalidChannelPriority';
ErrorCode{526}='ApiDmaManCorrupted';
ErrorCode{527}='ApiDmaInvalidElementIndex';
ErrorCode{528}='ApiDmaNoMoreElements';
ErrorCode{529}='ApiDmaSglInvalid';
ErrorCode{530}='ApiDmaSglQueueFull';
ErrorCode{531}='ApiNullParam';
ErrorCode{532}='ApiInvalidBusIndex';
ErrorCode{533}='ApiUnsupportedFunction';
ErrorCode{534}='ApiInvalidPciSpace';
ErrorCode{535}='ApiInvalidIopSpace';
ErrorCode{536}='ApiInvalidSize';
ErrorCode{537}='ApiInvalidAddress';
ErrorCode{538}='ApiInvalidAccessType';
ErrorCode{539}='ApiInvalidIndex';
ErrorCode{540}='ApiMuNotReady';
ErrorCode{541}='ApiMuFifoEmpty';
ErrorCode{542}='ApiMuFifoFull';
ErrorCode{543}='ApiInvalidRegister';
ErrorCode{544}='ApiDoorbellClearFailed';
ErrorCode{545}='ApiInvalidUserPin';
ErrorCode{546}='ApiInvalidUserState';
ErrorCode{547}='ApiEepromNotPresent';
ErrorCode{548}='ApiEepromTypeNotSupported';
ErrorCode{549}='ApiEepromBlank';
ErrorCode{550}='ApiConfigAccessFailed';
ErrorCode{551}='ApiInvalidDeviceInfo';
ErrorCode{552}='ApiNoActiveDriver';
ErrorCode{553}='ApiInsufficientResources';
ErrorCode{554}='ApiObjectAlreadyAllocated';
ErrorCode{555}='ApiAlreadyInitialized';
ErrorCode{556}='ApiNotInitialized';
ErrorCode{557}='ApiBadConfigRegEndianMode';
ErrorCode{558}='ApiInvalidPowerState';
ErrorCode{559}='ApiPowerDown';
ErrorCode{560}='ApiFlybyNotSupported';
ErrorCode{561}='ApiNotSupportThisChannel';
ErrorCode{562}='ApiNoAction';
ErrorCode{563}='ApiHSNotSupported';
ErrorCode{564}='ApiVPDNotSupported';
ErrorCode{565}='ApiVpdNotEnabled';
ErrorCode{566}='ApiNoMoreCap';
ErrorCode{567}='ApiInvalidOffset';
ErrorCode{568}='ApiBadPinDirection';
ErrorCode{569}='ApiPciTimeout';
ErrorCode{570}='ApiDmaChannelClosed';
ErrorCode{571}='ApiDmaChannelError';
ErrorCode{572}='ApiInvalidHandle';
ErrorCode{573}='ApiBufferNotReady';
ErrorCode{574}='ApiInvalidData';
ErrorCode{575}='ApiDoNothing';
ErrorCode{576}='ApiDmaSglBuildFailed';
ErrorCode{577}='ApiPMNotSupported';
ErrorCode{578}='ApiInvalidDriverVersion';
ErrorCode{579}='ApiWaitTimeout';
ErrorCode{580}='ApiWaitCanceled';
ErrorCode{581}='ApiBufferTooSmall';
ErrorCode{582}='ApiBufferOverflow';
ErrorCode{583}='ApiInvalidBuffer';
ErrorCode{584}='ApiInvalidRecordsPerBuffer';
ErrorCode{585}='ApiDmaPending';
ErrorCode{586}='ApiLockAndProbePagesFailed';
ErrorCode{587}='ApiWaitAbandoned';
ErrorCode{588}='ApiWaitFailed';
ErrorCode{589}='ApiTransferComplete';
ErrorCode{590}='ApiPLLNotLocked';
if code < length(ErrorCode) && ~isempty(ErrorCode{code})
    str=sprintf('%d: %s\n',code,ErrorCode{code});
else
    str=sprintf('%d: (unknown error)\n',code);
end
return