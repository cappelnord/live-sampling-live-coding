// live coding playground

(
t = 94 / 60;
TempoClock.default.tempo = t;
)

(
Ndef(\classic, {
	var sigs = 8.collect {BPF.ar(WhiteNoise.ar, (3000.0.rand + 2000).cpsmidi.floor.midicps, 0.005)};
	var sig;
	sigs = sigs * Lag2.ar(Decay.ar(Dust2.ar(1!8), 0.4), 0.001);

	sig = Splay.ar(sigs) * 8.9;

	sig = FbC({|fb| HPF.ar(PitchShift.ar(fb, 0.2, 1.25), 8000) * 0.8 + sig}, 2, 2);

	sig;
});
Ndef(\classic).quant = 4;
Ndef(\classic).fadeTime = 6
)

Ndef(\classic).play

(
SynthDef(\kick, {|out=0, freq=440, amp=0.1, pan=0, lmul=1|

	var sig = SinOsc.ar(freq * XLine.ar(5, 1, 0.01));
	var env = EnvGen.ar(Env.perc(0.0001, 0.3 * lmul, 1, -4), doneAction:2);
	sig = Pan2.ar(sig, pan) * env;

	sig = (sig * 3).tanh;

	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Ndef(\kick).quant = 4;
Ndef(\kick, Pbind(
	\instrument, \kick,
	\freq, 50,
	\amp, 0.8,
	\amp, 0.0,
	\dur, [1, 1, 1, 0.75, 0.25]!!inf
));
)



(
SynthDef(\hat, {|out=0, freq=440, amp=0.1, pan=0, lmul=1|

	var sig = WhiteNoise.ar;
	var env = EnvGen.ar(Env.perc(0.001, 0.1 * lmul, 1, -4), doneAction:2);
	sig = Pan2.ar(sig, pan) * env;

	sig = RHPF.ar(sig, XLine.kr(10000 + Rand(-100, 100), 5000, 0.1), 0.7);

	sig = (sig * 2).tanh * 0.5;

	OffsetOut.ar(out, sig * amp * env);
}).add;
)

(
Ndef(\hat).quant = 4;
Ndef(\hat, Pbind(
	\instrument, \hat,
	\amp, [1, 0.25, 1, 0]!!inf * 0.6,
	\amp, 0,
	\dur, 1/4,
	\dur, 2 / ([4, 8, 8, 4, 4, 4, 2, 8, 8, 2, 4, 4, 4, 8, 8, 8, 8]!!inf),
	\lmul, [0.5, 0.1, 1, 0.1, 2, 0.5]!!inf
));
)



(
SynthDef(\bass, {|out=0, freq=440, amp=0.1, pan=0|

	var sig = Mix.ar(Saw.ar(freq* [1, 2.001, 3 + Rand(-0.01, 0.01)])) * 0.6;
	var env = EnvGen.ar(Env.perc(0.0001, 0.3, 1, -4), doneAction:2);
	sig = Pan2.ar(sig, pan);

	sig = DFM1.ar(sig, XLine.ar(200, 100, 0.01), 0.5);

	sig = (sig * 2).tanh;

	OffsetOut.ar(out, sig * amp * env);
}).add;
)


(
Ndef(\bass).quant = 4;
Ndef(\bass, Pbind(
	\instrument, \bass,
	\octave, [3, 3, 3]!!inf,
	\scale, Scale.minorPentatonic,
	\amp, 0.6,
	\dur, [3, 3, 3, 3, 2, 2]!!inf / 2
));
)




(
SynthDef(\pling, {|out=0, freq=440, amp=0.1, pan=0, lmul=1|
	var mod = SinOsc.ar(freq * 2) * Line.ar(2 * freq, 0, 0.002);
	var sig = SinOsc.ar(freq + mod) * SinOsc.ar(Rand(1, 3), 0.5pi).range(0.5, 1);
	var env = EnvGen.ar(Env.perc(0.05, 0.1 * lmul, 1, -4), doneAction:2);
	sig = Pan2.ar(sig, pan) * env;

	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Ndef(\pling).quant = 4;
Ndef(\pling, Pbind(
	\instrument, \pling,
	\mtranspose, 0,
	\octave, [3, 4, 5, 6, 4, 4, 5, 4]!!inf,
	\scale, Scale.minorPentatonic,
	\degree, [0, 0, 1, 2, 0, 0, 0, -1, 0]!!inf,
	\degree, 0,
	\amp, 0.35 + Pwhite(0.05, 0.1),
	\dur, [2, 2, 1, 1, 2]!!inf / 2,
	\lmul, [1, 1, 4,1, 2, 10]!!inf * 1
));
)

(
Ndef(\mix, {
	var pling = Ndef(\pling).ar(2);
	var bass = Ndef(\bass).ar(2);
	var kick = Ndef(\kick).ar(2);
	var hat = Ndef(\hat).ar(2);
	var classic = Ndef(\classic).ar(2);
	var verb;
	var mix;
	pling = pling + FbC({|fb| fb * 0.8 + pling}, 1, 3/4/t);
	bass = bass + FbC({|fb| BPF.ar(fb * 0.8 + bass, SinOsc.kr(0.1).range(100, 400))}, 1, 1/4/t);
	hat = hat + FbC({|fb| RLPF.ar(fb * 0.4 + hat, SinOsc.kr(0.12).range(1000, 4000), 0.5)}, 1, 3/4/t);
	verb = JPverb.ar(hat * 0.2 + pling + bass + classic, 5) * 0.2;
	mix = pling  + bass + kick + hat * 0.6;
	(mix * 0.2) + (verb * 0.9) * 0.95;
})
)

Ndef(\mix).play

Ndef(\mix).fadeTime = 4

s.meter