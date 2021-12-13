if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
    if type -q fortune
        fortune -a
    end
end
