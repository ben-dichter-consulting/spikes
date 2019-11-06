function out=figureoutsamplerate

nwb = evalin('base', 'nwb');

nwb.loadAll
spiketimes=nwb.units.spike_times.data;

stind_temp=nwb.units.spike_times_index.loadAll;
stind=stind_temp.data;

spikescut=spiketimes(1:stind(1));

out=1/min(diff(spikescut));
end