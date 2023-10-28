
import os
import genanki
import random

def generate_anki_deck(question_folder, answer_folder):
    """
    Generate an Anki deck using images from the given folders.
    """

    model_id = random.randrange(1 << 30, 1 << 31)
    deck_id = random.randrange(1 << 30, 1 << 31)

    # Define Anki model
    my_model = genanki.Model(
        model_id=model_id,
        name='Simple Model',
        fields=[
            {'name': 'Question'},
            {'name': 'Answer'},
        ],
        templates=[
            {
                'name': 'Card 1',
                'qfmt': '{{Question}}',
                'afmt': '{{Answer}}',
            },
        ])

    # Initialize Anki deck
    my_deck = genanki.Deck(deck_id=deck_id, name='HS Battlegrounds Card Names')
    
    media_files = []
    
    for question_image, answer_image in zip(sorted(os.listdir(question_folder)), sorted(os.listdir(answer_folder))):
        # Add images to media_files list
        media_files.append(os.path.join(question_folder, question_image))
        media_files.append(os.path.join(answer_folder, answer_image))
        
        # Construct Anki card with images
        question_img_tag = f'<img src="{question_image}">'
        answer_img_tag = f'<img src="{answer_image}">'
        
        my_note = genanki.Note(
            model=my_model,
            fields=[question_img_tag, answer_img_tag])
        
        my_deck.add_note(my_note)
        
        print(f"Added card using question image: {question_image} and answer image: {answer_image}")

    # Generate Anki package with media files
    genanki.Package(my_deck, media_files=media_files).write_to_file('bg-card-names.apkg')
    print("Anki deck has been generated as output.apkg")

generate_anki_deck("images_updated", "images_source")
