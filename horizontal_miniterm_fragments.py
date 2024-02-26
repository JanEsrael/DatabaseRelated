

class HorizontalMinitermGenerator:
    def __init__(self, predicates):
        self.predicates = predicates

    def generate_fragments(self):
        fragments = []
        for predicate in self.predicates:
            fragments.extend(self.split_predicate(predicate))
        return fragments

    def split_predicate(self, predicate):
        fragments = []
        parts = predicate.split(' AND ')
        for part in parts:
            fragments.append(part)
        return fragments

#  i used these input  as an  Example to try the code  
predicates = [
    "A = 1 AND B = 2",
    "C = 3 AND D = 4"
]

generator = HorizontalMinitermGenerator(predicates)
fragments = generator.generate_fragments()
for fragment in fragments:
    print(fragment)
