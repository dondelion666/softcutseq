m = midi.connect(4)

mc8={0,0,0,0,0,0,0,0}



s_clock={64,64,64,64,64,64,64,64}
s_rate={64,64,64,64,64,64,64,64}
s_start={64,64,64,64,64,64,64,64}
s_length={64,64,64,64,64,64,64,64}

pages={'s_clock','s_rate','s_start','s_length'}
s_lengths={4,4,4,4}

page=1
duration=0
clock_div=4

clock_count=1
rate_count=1
start_count=1
length_count=1

m.event = function(data)
  local d = midi.to_msg(data)
  if d.type == "cc" then
    local a=d.cc+1
    local b=d.val
    midi_cc_refresh(a,b)
  end
end

function init()
  
  params:add_file('sample','sample')
  params:set_action('sample',function (x) read_file(x) end)
  
  params:add_number('clock_div','clock div',2,23,4)
  params:set_action('clock_div', function (x) clock_div=x end)
  
  softcut.enable(1,1)
  softcut.buffer(1,1)
  softcut.level(1,1.0)
  softcut.loop(1,1)
  softcut.loop_start(1,0)
  softcut.loop_end(1,0)
  softcut.position(1,1)
  softcut.play(1,1)
  
  clock.run(redraw_clock)
  
end

function redraw_clock()
  while true do
    redraw()
    clock.sleep(1/15)
  end
end

function midi_cc_refresh(x,y)
  if page==1 then
    s_clock[x]=y
  elseif page==2 then
    s_rate[x]=y
  elseif page==3 then
    s_start[x]=y
  elseif page==4 then
    s_length[x]=y
  end
end

function enc(n,d)
  if n==1 then
    page=util.clamp(page+d,1,4)
  elseif n==3 then
    s_lengths[page]=util.clamp(s_lengths[page]+d,1,8)
  end
end

function key(n,z)
  if n==2 and z==1 then
    clock.run(lfo)
  end
end

function lfo()
  while true do
    
    clock_count=util.wrap(clock_count+1,1,s_lengths[1])
    clock.sync(math.ceil((s_clock[clock_count]/127)*clock_div)/clock_div)
    lfo_update()
  end
end

function lfo_update()
  
  rate_count=util.wrap(rate_count+1,1,s_lengths[2])
  softcut.rate(1,4*(s_rate[rate_count]/127))
  
  start_count=util.wrap(start_count+1,1,s_lengths[3])
  softcut.loop_start(1,duration*(s_start[start_count]/127))
  
  length_count=util.wrap(length_count+1,1,s_lengths[4])
  softcut.loop_end(1,util.clamp(duration*((s_start[start_count]+s_length[length_count])/127),0,duration))
  
end

function read_file(x)
  softcut.buffer_read_mono(x,0,0,-1,1,1)
  ch,length,sr = audio.file_info(x)
  duration=length/sr
  softcut.loop_end(1,duration)
end

function redraw()
  screen.clear()
  screen.move(4,8)
  screen.level(15)
  screen.text(pages[page]..' '..s_lengths[page])
  
  screen.move(0,16)
  
  
    if page==1 then
    for i=1,s_lengths[page] do
      screen.text(s_clock[i]..' ')
    end
    elseif page==2 then
    for i=1,s_lengths[page] do
      screen.text(s_rate[i]..' ')
    end
    elseif page==3 then
    for i=1,s_lengths[page] do
      screen.text(s_start[i]..' ')
    end
    elseif page==4 then
    for i=1,s_lengths[page] do
      screen.text(s_length[i]..' ')
    end
    end
  
  screen.update()
    
end
