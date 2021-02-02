(
s.options.sampleRate = 44100;
s.options.device = "ASIO : MOTU Pro Audio";
s.options.numInputBusChannels = 4;
s.options.numOutputBusChannels = 4;
s.latency = 0.5;
)

s.scope

(
t = 94 / 60;
TempoClock.default.tempo = t;
)


s.boot;
"buf.scd".loadRelative

(
~bufInit.value((
	inChannel: 2,
	monitChannel: 2,
	dir: Document.current.dir +/+ "samples"
));
)

~bufRestore.();
~bufMonit.value(\one)

s.scope

s.meter

().play

~bufRecord.value(\ipad, 10)

~bufMonit.value(\ipad)