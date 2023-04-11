<?php

namespace App\DataFixtures;

use App\Entity\Task;
use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;
use Faker\Generator;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class AppFixtures extends Fixture
{
    private Generator $faker;

    public function __construct(private UserPasswordHasherInterface $hasher)
    {
        $this->faker = Factory::create('fr_FR');
    }

    public function load(ObjectManager $manager): void
    {
        $user1 = new User();
        $user1->setEmail('test@test.fr')
            ->setRoles(['ROLE_ADMIN', 'ROLE_USER'])
            ->setPassword(
                $this->hasher->hashPassword($user1, 'test@test.fr')
            );
        $manager->persist($user1);

        for ($i = 0; $i <= 10; ++$i) {
            $user = new User();
            $user->setEmail('test'.$i.'@test.fr')
                ->setRoles(['ROLE_USER'])
                ->setPassword(
                    $this->hasher->hashPassword($user, 'test'.$i.'@test.fr')
                );

            $manager->persist($user);
        }
        for ($i = 0; $i <= 10; ++$i) {
            $task = new Task();
            $task->setName($this->faker->sentence(4))
            ->setContent($this->faker->paragraph())
            ->setUser($user1)
            // ->setCreatedAt(new \DateTime('now'))
            // ->setUpdatedAt(new \DateTime('now'))
            ;
            $manager->persist($task);
        }

        $manager->flush();
    }
}
