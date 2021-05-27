require 'pstore'
require 'optparse'

@store = PStore.new('answers.pstore')

@options = {}
def parse_options
    OptionParser.new do |opts|
        opts.on("-r", "--report", "Show Summary Report Statistics") {
            print_report()
            exit
        }

        opts.on("-h", "--help", "Show This Help Text") { 
            puts opts; exit 
        }

        opts.on("-c", "--continuous", "Continously Run Questionare") {
            @options[:continuous] = true
        }
    end.parse!
end


def print_report() 
    @store.transaction(true) do
        print @store[:answers]
    end
end


@questions = {
    "ruby"   => "Can you code in Ruby?",
    "js"     => "Can you code in Javascript?",
    "swift"  => "Can you code in Swift (iOS)?",
    "java"   => "Can you code in Java (Android)?",
    "csharp" => "Can you code in C#?"
}

def run_questionare

    run = Hash.new

    @questions.each_key do |key|
        loop do
            print @questions[key]
            ans = gets.chomp

            if ans == "y" || ans == "yes"
                run[key] = "y"
                break

            elsif ans == "n" || ans == "no"
                run[key] = "n"
                break

            else
                print "Please type yes or no. \n"
            end
        end
    end
    
    @store.transaction do
        @store[:answers] ||= Array.new
        @store[:answers].push(run)
    end
end

parse_options

run_questionare