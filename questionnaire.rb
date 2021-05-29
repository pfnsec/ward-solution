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

        opts.on("-c", "--continuous", "Continously Run Questionnaire") {
            @options[:continuous] = true
        }
    end.parse!
end

@questions = {
    "ruby"   => "Can you code in Ruby?",
    "js"     => "Can you code in Javascript?",
    "swift"  => "Can you code in Swift (iOS)?",
    "java"   => "Can you code in Java (Android)?",
    "csharp" => "Can you code in C#?"
}

def print_report() 
    count = 0
    total = 0
    @store.transaction(true) do
        # For every questionnaire run...
        @store[:answers].each do |run|
            # ...Take each question asked, 
            # and increase the total if it's "y".
            @questions.each_key do |question|
                if run[question] == "y"
                    count += 1
                end
                total += 1
            end

        end
    end

    # Compute the average over all runs
    # (It's rounded to int per the spec)
    average = 100 * count / total

    print "Average score for all runs: ", average, "\n"

end


def run_questionnaire

    run = Hash.new

    total = 0

    # Ask each question and take an answer from user input.
    @questions.each_key do |key|
        loop do
            print @questions[key]
            ans = gets.chomp

            if ans == "y" || ans == "yes"
                run[key] = "y"
                total += 1
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

    score = 100 * total / @questions.length

    print "Run score: ", score, "/100\n"
end

parse_options

if @options[:continuous] 
    loop do
        run_questionnaire
    end
else
    run_questionnaire 
end

print_report