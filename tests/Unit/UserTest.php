<?php
declare(strict_types=1);
namespace App\Tests\Unit;

use App\Entity\Task;
use App\Entity\User;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

class UserTest extends KernelTestCase
{
    public function getEntity(): User
    {
        return (new User())->setEmail('phpunit@test.com')->setPassword('password');
    }

    public function testNewUserIsInstanceOfUserClass(): void
    {
        $user = $this->getEntity();
        self::assertInstanceOf(User::class, $user);
    }

    public function testUserAssertsAreValid(): void
    {
        self::bootKernel();
        $container = static::getContainer();

        $user = $this->getEntity();

        $errors = $container->get('validator')->validate($user);

        self::assertEquals('password', $user->getPassword());
        self::assertEquals('phpunit@test.com', $user->getEmail());
        self::assertEquals('phpunit@test.com', $user->getUserIdentifier());
        self::assertCount(0, $errors);
    }

    public function testUserAssertsAreInvalid(): void
    {
        self::bootKernel();
        $container = static::getContainer();

        $user = $this->getEntity();
        $user->setEmail('');
        $user->setPassword('');

        $errors = $container->get('validator')->validate($user);

        self::assertNotEquals('password', $user->getPassword());
        self::assertNotEquals('phpunit@test.com', $user->getEmail());
        self::assertCount(2, $errors);
    }

    public function testUserGetRoles(): void
    {
        self::bootKernel();
        $container = static::getContainer();

        $user = $this->getEntity();

        $value = ['ROLE_ADMIN'];

        $response = $user->setRoles($value);

        self::assertInstanceOf(User::class, $response);
        self::assertContains('ROLE_USER', $user->getRoles());
        self::assertContains('ROLE_ADMIN', $user->getRoles());
    }

    public function testUserAddAndRemoveTask(): void
    {
        $task = new Task();

        $user = $this->getEntity();
        $response = $user->addTask($task);

        self::assertInstanceOf(User::class, $response);
        self::assertCount(1, $user->getTasks());
        self::assertTrue($user->getTasks()->contains($task));

        $response = $user->removeTask($task);

        self::assertInstanceOf(User::class, $response);
        self::assertCount(0, $user->getTasks());
        self::assertFalse($user->getTasks()->contains($task));
    }

    public function testUserAddAndRemoveFewTasks(): void
    {
        $value = new Task();
        $value1 = new Task();
        $value2 = new Task();

        $user = $this->getEntity();

        $user->addTask($value);
        $user->addTask($value1);
        $user->addTask($value2);

        self::assertCount(3, $user->getTasks());
        self::assertTrue($user->getTasks()->contains($value));
        self::assertTrue($user->getTasks()->contains($value1));
        self::assertTrue($user->getTasks()->contains($value2));

        $response = $user->removeTask($value);

        self::assertInstanceOf(User::class, $response);
        self::assertCount(2, $user->getTasks());
        self::assertFalse($user->getTasks()->contains($value));
        self::assertTrue($user->getTasks()->contains($value1));
        self::assertTrue($user->getTasks()->contains($value2));
    }
}