# NOTE: this is NOT a database model! We only store strings.
class Rank
  class << self
    attr_accessor :ordered, :unordered, :abbrs, :prefixes

    def all
      @ordered
    end

    def add_prefixes(basenames)
      basenames.flat_map { |b| @prefixes.map { |p| p == '-' ? b : "#{p}#{b}" } }
    end

    def sort(array)
      scores = {}
      array.each do |el|
        scores[el] = ordered.index(el.downcase.gsub(/\s/, ''))
      end
      array.sort do |a,b|
        if scores[a].nil? || scores[b].nil?
          0
        else
          scores[a] <=> scores[b]
        end
      end
    end

      def clean(verbatim)
      cleaned = verbatim.downcase # We don't allow caps (at all); these are meant to be I18n symbols!
      cleaned.gsub!(/\s+/, ' ') # Normalize all spaces
      cleaned.gsub!(/[^ a-z]/, '') # remove all non-alpha characters, including ALL punctuation! Yes, really.
      cleaned.sub!(/^\s/, '') # No starting space
      cleaned.sub!(/\s$/, '') # No ending space
      return '' unless verbatim.match?(/[a-z]/) # There are some wonky values; ignore them.
      words = []
      cleaned.split.each do |word|
        prefix = nil
        if (prefix = find_prefix(word))
          word.sub!(/^#{prefix}/, '')
        end
        word = abbrs[word] if abbrs.key?(word)
        unless word.blank?
          words << prefix if prefix
          words << word
        end
      end
      cleaned = words.join
      cleaned.sub!(/group$/, '_group')
      cleaned
    end

    def find_prefix(word)
      prefixes.each do |pref|
        if word.match?(/^#{pref}/)
          return pref
        end
      end
      nil
    end
  end

  # These were provided by Katja and are in order:
  @base_names = %w[
    domain
    kingdom
    phylum
    class
    cohort
    division
    order
    family
    tribe
    genus
  ] + ['species group'] + %w[
    species
    variety
    form
  ]

  @abbrs = {
    'dom' => 'domain',
    'domains' => 'domain',
    'k' => 'kingdom',
    'king' => 'kingdom',
    'kin' => 'kingdom',
    'kingdom' => 'kingdom',
    'p' => 'phylum',
    'ph' => 'phylum',
    'phy' => 'phylum',
    'phyl' => 'phylum',
    'phyla' => 'phylum',
    'phylums' => 'phylum',
    'c' => 'class',
    'cl' => 'class',
    'cls' => 'class',
    'classes' => 'class',
    'classa' => 'class',
    'co' => 'cohort',
    'coh' => 'cohort',
    'cohorts' => 'cohort',
    'div' => 'division',
    'divisions' => 'division',
    'o' => 'order',
    'ord' => 'order',
    'orders' => 'order',
    'f' => 'family',
    'fam' => 'family',
    'families' => 'family',
    'familha' => 'family',
    'familia' => 'family',
    't' => 'tribe',
    'tribes' => 'tribe',
    'g' => 'genus',
    'genuses' => 'genus',
    'genera' => 'genus',
    'genre' => 'genus',
    'gen' => 'genus',
    'generic' => 'genus',
    's' => 'species',
    'sp' => 'species',
    'specific' => 'species',
    'spesies' => 'species', # Known misspelling
    'espesye' => 'species', # Known misspelling (another lang, maybe?)
    'especie' => 'species', # Known misspelling (another lang, maybe?)
    'v' => 'variety',
    'var' => 'variety',
    'varieties' => 'variety',
    'varietas' => 'variety',
    'for' => 'form',
    'frm' => 'form',
    'fm' => 'form',
    'forms' => 'form',
    'forma' => 'form',
    'subsp' => 'subspecies',
    'subspesies' => 'subspecies', # Known misspelling
    'subgen' => 'subgenus',
    'ss' => 'subspecies',
    'sec' => 'section',
    'sect' => 'section',
    'sections' => 'section',
    'ser' => 'series',
    'cld' => 'clade',
    'clades' => 'clade',
    'unranked' => '',
    'fsp' => 'forma_specialis', # Err... not sure we *care* about this one, but...
    # KNOWN JUNK NAMES:
    'suprageneric' => '',
    'specificname' => ''
  }

  @groups = 'paraphyletic group' + 'polyphyletic group'

  @prefixes = %w[mega super epi sub infra subter]
  @ordered = Rank.add_prefixes(@base_names)
  @unordered_base_names = %w[section series clade]
  @unordered = Rank.add_prefixes(@unordered_base_names)

end
